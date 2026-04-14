import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/room.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5001/api'; 
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
  }

  Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ?? 'tenant';
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    if (token != null) {
      return {'Content-Type': 'application/json', 'x-auth-token': token};
    }
    return {'Content-Type': 'application/json'};
  }

  // --- Auth Methods ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Server returned empty response'};
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await saveToken(data['token']);
        return {'success': true, 'token': data['token'], 'user': User.fromJson(data['user'])};
      }
      return {'success': false, 'message': data['msg'] ?? 'Login failed'};
    } catch (e) {
      print('Login Error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Server returned empty response'};
      }

      // Check if response is JSON
      try {
        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          await saveToken(data['token']);
          return {'success': true, 'token': data['token']};
        }
        return {'success': false, 'message': data['msg'] ?? 'Registration failed'};
      } catch (e) {
        print('JSON Decode Error: $e');
        print('Response body: ${response.body}');
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Registration Network Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }


  // --- Users & Profiles ---
  Future<User?> getMe() async {
    final response = await http.get(Uri.parse("$baseUrl/users/me"), headers: await _authHeaders());
    if (response.statusCode == 200) return User.fromJson(jsonDecode(response.body));
    return null;
  }
  
  Future<bool> updateProfile(Map<String, dynamic> body) async {
    final response = await http.put(Uri.parse("$baseUrl/users/me"), headers: await _authHeaders(), body: jsonEncode(body));
    return response.statusCode == 200;
  }

  Future<List<String>> toggleFavorite(String roomId) async {
    final response = await http.post(Uri.parse("$baseUrl/users/favorites/$roomId"), headers: await _authHeaders());
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }
    return [];
  }

  Future<List<Room>> getFavorites() async {
    final response = await http.get(Uri.parse("$baseUrl/users/favorites"), headers: await _authHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Room.fromJson(json)).toList();
    }
    return [];
  }

  // --- Rooms ---
  Future<List<Room>> getRooms({Map<String, String>? filters}) async {
    final uri = Uri.parse("$baseUrl/rooms").replace(queryParameters: filters);
    final response = await http.get(uri, headers: await _authHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Room.fromJson(json)).toList();
    }
    return [];
  }

  Future<Room?> getRoomById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/rooms/$id"), headers: await _authHeaders());
    if (response.statusCode == 200) return Room.fromJson(jsonDecode(response.body));
    return null;
  }

  Future<bool> createRoom(Map<String, dynamic> roomData, List<String> filePaths) async {
    final token = await getToken();
    final uri = Uri.parse("$baseUrl/rooms");
    final request = http.MultipartRequest('POST', uri);

    // Add Auth Header
    if (token != null) {
      request.headers['x-auth-token'] = token;
    }

    // Add Fields
    roomData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add Files
    for (String path in filePaths) {
      request.files.add(await http.MultipartFile.fromPath('media', path));
    }

    final response = await request.send();
    return response.statusCode == 201;
  }

  Future<bool> deleteRoom(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/rooms/$id"), headers: await _authHeaders());
    return response.statusCode == 200;
  }

  Future<bool> updateRoom(String id, Map<String, dynamic> roomData, List<String> newFilePaths) async {
    final token = await getToken();
    final uri = Uri.parse("$baseUrl/rooms/$id");
    final request = http.MultipartRequest('PUT', uri);

    // Add Auth Header
    if (token != null) {
      request.headers['x-auth-token'] = token;
    }

    // Add Fields
    roomData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add New Files
    for (String path in newFilePaths) {
      request.files.add(await http.MultipartFile.fromPath('media', path));
    }

    final response = await request.send();
    return response.statusCode == 200;
  }

  // --- Bookings ---
  Future<bool> createBooking(String roomId, String startDate, num amount) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bookings"),
      headers: await _authHeaders(),
      body: jsonEncode({'roomId': roomId, 'startDate': startDate, 'amount': amount})
    );
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>?> createRazorpayOrder(num amount) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bookings/create-order"),
      headers: await _authHeaders(),
      body: jsonEncode({'amount': amount}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }

  Future<bool> verifyRazorpayPayment(Map<String, dynamic> paymentData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bookings/verify-payment"),
      headers: await _authHeaders(),
      body: jsonEncode(paymentData),
    );
    return response.statusCode == 200;
  }

  Future<List<dynamic>> getMyBookings() async {
    final response = await http.get(Uri.parse("$baseUrl/bookings/my"), headers: await _authHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  // --- Owner Specific ---
  Future<List<Room>> getOwnerRooms() async {
    final response = await http.get(Uri.parse("$baseUrl/rooms/owner/my-listings"), headers: await _authHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Room.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<dynamic>> getOwnerBookings() async {
    final response = await http.get(Uri.parse("$baseUrl/bookings/owner/my"), headers: await _authHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    final response = await http.put(
      Uri.parse("$baseUrl/bookings/$bookingId/status"),
      headers: await _authHeaders(),
      body: jsonEncode({'status': status})
    );
    return response.statusCode == 200;
  }

  // --- Messages ---
  Future<List<dynamic>> getChatThreads() async {
    final response = await http.get(Uri.parse("$baseUrl/messages"), headers: await _authHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<List<dynamic>> getThreadMessages(String roomId, String userId) async {
    final response = await http.get(Uri.parse("$baseUrl/messages/$roomId/$userId"), headers: await _authHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<bool> sendMessage(String receiverId, String roomId, String content) async {
    final response = await http.post(
      Uri.parse("$baseUrl/messages"),
      headers: await _authHeaders(),
      body: jsonEncode({'receiverId': receiverId, 'roomId': roomId, 'content': content})
    );
    return response.statusCode == 200;
  }
}
