import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:green_share/services/ai_service.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/models/item_model.dart';
import 'package:green_share/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_share/screens/post/location_picker_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:green_share/main.dart'; // import context extension
import 'package:flutter/foundation.dart' show kIsWeb;

class PostItemScreen extends StatefulWidget {
  const PostItemScreen({super.key});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _type = 'Donate';
  String _condition = 'Good';
  final List<String> _conditions = ['New', 'Good', 'Fair', 'Poor'];
  
  String _selectedCategory = 'Other';
  final List<String> _categories = [
    'Clothing',
    'Furniture',
    'Books',
    'Electronics',
    'Toys',
    'Other'
  ];
  
  String _selectedCity = 'Amman';
  final List<String> _cities = [
    'Amman',
    'Zarqa',
    'Irbid',
    'Aqaba',
    'Mafraq',
    'Jerash',
    'Madaba',
    'Other'
  ];
  
  LatLng? _selectedLocation;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final AIService _aiService = AIService();
  final DatabaseService _databaseService = DatabaseService();
  bool _isProcessingImage = false;
  bool _isUploading = false;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _autoLocateUser();
  }

  Future<void> _autoLocateUser() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    
    setState(() => _isLoadingLocation = true);
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.locationDisabled)),
        );
        setState(() => _isLoadingLocation = false);
      }
      if (!kIsWeb) {
        await Geolocator.openLocationSettings();
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.locationDenied)),
          );
          setState(() => _isLoadingLocation = false);
        }
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.locationPermDenied)),
        );
        setState(() => _isLoadingLocation = false);
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (mounted) {
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.locationFailed)),
        );
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _isProcessingImage = true;
      });
      
      final category = await _aiService.classifyImage(pickedFile);
      
      setState(() {
        _isProcessingImage = false;
        if (category != null && _categories.contains(category)) {
          _selectedCategory = category;
        } else if (category != null) {
          _selectedCategory = 'Other';
        }
      });
    }
  }

  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseEnterTitle)),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous_user';
      List<String> uploadedImageUrls = [];

      if (_imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.name}';
        final url = await _databaseService.uploadImage(File(_imageFile!.path), 'item_images/$fileName');
        if (url != null) {
          uploadedImageUrls.add(url);
        }
      }

      final item = ItemModel(
        id: '', // Will be generated by Firestore
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type,
        category: _selectedCategory,
        condition: _condition,
        imageUrls: uploadedImageUrls,
        ownerId: userId,
        postedAt: DateTime.now(),
        location: _selectedLocation != null ? 'Selected on Map' : 'Unknown Location',
        city: _selectedCity,
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
        status: 'available',
      );

      await _databaseService.addItem(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.itemPostedSuccess)),
        );
        
        // Clear form
        _titleController.clear();
        _descriptionController.clear();
        _selectedCategory = 'Other';
        _selectedCity = 'Amman';
        setState(() {
          _imageFile = null;
          _selectedLocation = null;
          _isUploading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorPostingItem(e.toString()))),
        );
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.postItem),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                context.l10n.readyToShare,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.pleaseLoginToPost,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<UserModel?>(
      future: _databaseService.getUserProfile(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final userModel = snapshot.data;
        if (userModel != null && userModel.role == 'Charity' && !userModel.isApproved) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.postItem),
              automaticallyImplyLeading: false,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pending_actions, size: 60, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.accountPendingApproval,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.postItem),
            automaticallyImplyLeading: false, // Don't show back button inside tab bar
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text(context.l10n.donate),
                  selected: _type == 'Donate',
                  onSelected: (val) {
                    if (val) setState(() => _type = 'Donate');
                  },
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: Text(context.l10n.request),
                  selected: _type == 'Request',
                  onSelected: (val) {
                    if (val) setState(() => _type = 'Request');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.none),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                      )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(context.l10n.tapToAddPhoto, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isProcessingImage)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 8),
                  Text(context.l10n.aiInterpreting),
                ],
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: context.l10n.title),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(labelText: context.l10n.categoryAutoFilled),
              items: _categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: context.l10n.description),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            if (_type == 'Donate')
              DropdownButtonFormField<String>(
                initialValue: _condition,
                decoration: InputDecoration(labelText: context.l10n.condition),
                items: _conditions.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _condition = val);
                },
              ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: _selectedCity),
              decoration: InputDecoration(labelText: context.l10n.city),
              readOnly: true,
              enabled: false,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: Text(_selectedLocation == null 
                  ? (_isLoadingLocation ? context.l10n.locating : context.l10n.selectLocation) 
                  : context.l10n.locationSelected),
              subtitle: Text(_selectedLocation == null 
                  ? (_isLoadingLocation ? context.l10n.gettingCurrentLocation : context.l10n.tapToChooseOnMap) 
                  : '${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}'),
              trailing: _isLoadingLocation 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.chevron_right),
              onTap: _isLoadingLocation ? null : () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
                );
                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    _selectedLocation = result['location'] as LatLng?;
                    
                    final String? city = result['city'] as String?;
                    if (city != null) {
                      bool cityExists = _cities.any((c) => c.toLowerCase() == city.toLowerCase());
                      if (cityExists) {
                        _selectedCity = _cities.firstWhere((c) => c.toLowerCase() == city.toLowerCase());
                      } else {
                        _cities.insert(0, city);
                        _selectedCity = city;
                      }
                    }
                  });
                } else if (result != null && result is LatLng) {
                  setState(() {
                    _selectedLocation = result;
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitPost,
                    child: Text(context.l10n.postButton),
                  ),
          ],
        ),
      ),
    );
      },
    );
  }
}
