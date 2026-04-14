import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import '../models/room.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'location_picker_screen.dart';

class EditRoomScreen extends StatefulWidget {
  final Room room;
  const EditRoomScreen({super.key, required this.room});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _rentCtrl;
  final _apiService = ApiService();
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _newFiles = [];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.room.title);
    _cityCtrl = TextEditingController(text: widget.room.city);
    _rentCtrl = TextEditingController(text: widget.room.rent.toString());
    _latitude = widget.room.latitude;
    _longitude = widget.room.longitude;
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _newFiles = [..._newFiles, ...images];
      });
    }
  }

  void _submit() async {
    if (_titleCtrl.text.isEmpty || _rentCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in required fields')));
      return;
    }

    setState(() => _isLoading = true);
    
    final roomData = {
      'title': _titleCtrl.text,
      'city': _cityCtrl.text,
      'rent': int.tryParse(_rentCtrl.text) ?? widget.room.rent,
      'latitude': _latitude,
      'longitude': _longitude,
    };

    final newPaths = _newFiles.map((f) => f.path).toList();

    final success = await _apiService.updateRoom(widget.room.id, roomData, newPaths);
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room updated successfully!')));
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update room.')));
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _cityCtrl.dispose();
    _rentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Property'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Listing Details', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
            
            TextField(
              controller: _titleCtrl, 
              decoration: const InputDecoration(labelText: 'Listing Title', prefixIcon: Icon(Icons.title)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cityCtrl, 
              decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rentCtrl, 
              decoration: const InputDecoration(labelText: 'Monthly Rent (₹)', prefixIcon: Icon(Icons.currency_rupee)), 
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Location Picker Button
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.location_on, color: AppTheme.primaryColor),
                title: const Text('Property Location', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_latitude != null 
                  ? 'Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}' 
                  : 'Pin exact location on map'),
                trailing: const Icon(Icons.map_outlined),
                onTap: () async {
                  final LatLng? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationPickerScreen(
                        initialLocation: _latitude != null ? LatLng(_latitude!, _longitude!) : const LatLng(28.6139, 77.2090),
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _latitude = result.latitude;
                      _longitude = result.longitude;
                    });
                  }
                },
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Add New Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            
            if (_newFiles.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _newFiles.length,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(File(_newFiles[index].path)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add More Images'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text('Update Property', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
