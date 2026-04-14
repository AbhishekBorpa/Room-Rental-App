import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'location_picker_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _titleCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'Mumbai');
  final _rentCtrl = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedFiles = [];

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedFiles = [..._selectedFiles, ...images];
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
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
      'rent': int.tryParse(_rentCtrl.text) ?? 5000,
      'roomType': 'single',
      'furnishing': 'semi',
      'latitude': _latitude,
      'longitude': _longitude,
    };

    final filePaths = _selectedFiles.map((f) => f.path).toList();

    final success = await _apiService.createRoom(roomData, filePaths);
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room posted successfully!')));
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to post room. Check backend logs.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Property')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Property Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Listing Title (e.g. Spacious 1BHK)')),
            const SizedBox(height: 16),
            TextField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City')),
            const SizedBox(height: 16),
            TextField(controller: _rentCtrl, decoration: const InputDecoration(labelText: 'Monthly Rent (₹)'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            
            // Location Picker Button
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.location_on, color: AppTheme.primaryColor),
                title: const Text('Pin on Map', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_latitude != null 
                  ? 'Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}' 
                  : 'Specify exact location for better reach'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final LatLng? result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
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
            
            Text('Photos & Media', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const Text('Upload clear photos of the room, kitchen and locality.', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            const SizedBox(height: 16),
            
            // Image Preview Area
            if (_selectedFiles.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(_selectedFiles[index].path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 16,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add Images'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Post Room Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
