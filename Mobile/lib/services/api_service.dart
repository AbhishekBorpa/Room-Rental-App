import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/room.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; 
  
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
    final response = await http.post(
      Uri.parse('\$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await saveToken(data['token']);
      return {'success': true, 'token': data['token'], 'user': User.fromJson(data['user'])};
    }
    return {'success': false, 'message': data['msg'] ?? 'Login failed'};
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('\$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await saveToken(data['token']);
      return {'success': true, 'token': data['token']};
    }
    return {'success': false, 'message': data['msg'] ?? 'Registration failed'};
  }

  // --- Users & Profiles ---
  Future<User?> getMe() async {
    final response = await http.get(Uri.parse('\$baseUrl/users/me'), headers: await _authHeaders());
    if (response.statusCode == 200) return User.fromJson(jsonDecode(response.body));
    return null;
  }
  
  Future<bool> updateProfile(Map<String, dynamic> body) async {
    final response = await http.put(Uri.parse('\$baseUrl/users/me'), headers: await _authHeaders(), body: jsonEncode(body));
    return response.statusCode == 200;
  }

  Future<List<String>> toggleFavorite(String roomId) async {
    final response = await http.post(Uri.parse('\$baseUrl/users/favorites/\$roomId'), headers: await _authHeaders());
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }
    return [];
  }

  Future<List<Room>> getFavorites() async {
    final response = await http.get(Uri.parse('\$baseUrl/users/favorites'), headers: await _authHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Room.fromJson(json)).toList();
    }
    return [];
  }

  // --- Rooms ---
  Future<List<Room>> getRooms({Map<String, String>? filters}) async {
    final uri = Uri.parse('\$baseUrl/rooms').replace(queryParameters: filters);
    final response = await http.get(uri, headers: await _authHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Room.fromJson(json)).toList();
    }
    return [];
  }

  Future<Room?> getRoomById(String id) async {
    final response = await http.get(Uri.parse('\$baseUrl/rooms/\$id'), headers: await _authHeaders());
    if (response.statusCode == 200) return Room.fromJson(jsonDecode(response.body));
    return null;
  }

  Future<bool> createRoom(Map<String, dynamic> roomData) async {
    final response = await http.post(
      Uri.parse('\$baseUrl/rooms'),
      headers: await _authHeaders(),
      body: jsonEncode(roomData)
    );
    return response.statusCode == 201;
  }

  // --- Bookings ---
  Future<bool> createBooking(String roomId, String startDate, num amount) async {
    final response = await http.post(
      Uri.parse('\$baseUrl/bookings'),
      headers: await _authHeaders(),
      body: jsonEncode({'roomId': roomId, 'startDate': startDate, 'amount': amount})
    );
    return response.statusCode == 200;
  }

  Future<List<dynamic>> getMyBookings() async {
    final response = await http.get(Uri.parse('\$baseUrl/bookings/my'), headers: await _authHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  // --- Messages ---
  Future<List<dynamic>> getChatThreads() async {
    final response = await http.get(Uri.parse('\$baseUrl/messages'), headers: await _authHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<List<dynamic>> getThreadMessages(String roomId, String userId) async {
    final response = await http.get(Uri.parse('\$baseUrl/messages/\$roomId/\$userId'), headers: await _authHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<bool> sendMessage(String receiverId, String roomId, String content) async {
    final response = await http.post(
      Uri.parse('\$baseUrl/messages'),
      headers: await _authHeaders(),
      body: jsonEncode({'receiverId': receiverId, 'roomId': roomId, 'content': content})
    );
    return response.statusCode == 200;
  }
}
