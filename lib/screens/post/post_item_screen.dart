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
import 'package:flutter/foundation.dart'; // import kIsWeb
import 'package:flutter/services.dart'; // import Uint8List
import 'package:green_share/core/localization_helpers.dart';

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
  final List<String> _conditions = ['New', 'Like New', 'Good', 'Fair'];
  
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
    'Madaba',
    'Karak',
    'Ma\'an',
    'Tafilah',
    'Ajloun',
    'Jerash',
    'Mafraq',
    'Balqa',
    'Other'
  ];
  
  LatLng? _selectedLocation;
  List<XFile> _imageFiles = [];
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

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles.addAll(pickedFiles);
        // Start showing the "AI is interpreting..." loader
        _isProcessingImage = true; 
      });

      try {
        // Run AI classification on the first image picked
        final String? detectedCategory = await _aiService.classifyImage(pickedFiles.first);

        if (mounted && detectedCategory != null) {
          setState(() {
            // Check if the AI's result exists in your predefined _categories list
            if (_categories.contains(detectedCategory)) {
              _selectedCategory = detectedCategory;
            } else {
              _selectedCategory = 'Other';
            }
          });

          // Optional: Show a snackbar to let the user know AI helped
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("AI detected: $detectedCategory"),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (mounted && detectedCategory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("AI Classification failed. Check API Key or Console."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint("AI Error: $e");
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("AI Error: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // Hide the loader regardless of success or failure
        if (mounted) {
          setState(() => _isProcessingImage = false);
        }
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    if (_imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseEnterTitle)),
      );
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'anonymous_user';
      List<String> uploadedImageUrls = [];

      // Upload each compressed image natively
      for (var xfile in _imageFiles) {
        Uint8List bytes = await xfile.readAsBytes();
        String? url = await _databaseService.uploadImage(bytes, 'items/${userId}_${DateTime.now().millisecondsSinceEpoch}_${_imageFiles.indexOf(xfile)}.jpg');
        if (url != null) uploadedImageUrls.add(url);
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
          _imageFiles.clear();
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
  void dispose() {
    // Clean up controllers
    _titleController.dispose();
    _descriptionController.dispose();
    
    // CRITICAL: Close the ML Kit Image Labeler
    _aiService.dispose(); 
    
    super.dispose();
  }
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
            if (_imageFiles.isEmpty)
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.none),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(context.l10n.tapToAddPhoto, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _imageFiles.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _imageFiles.length) {
                              return GestureDetector(
                                onTap: _pickImages,
                                child: Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                  ),
                                ),
                              );
                            }
                            return Stack(
                              children: [
                                Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: kIsWeb 
                                      ? Image.network(
                                          _imageFiles[index].path,
                                          fit: BoxFit.cover,
                                          width: 160,
                                          height: 200,
                                        )
                                      : Image.file(
                                          File(_imageFiles[index].path),
                                          fit: BoxFit.cover,
                                          width: 160,
                                          height: 200,
                                        ),
                                  ),
                                ),
                            Positioned(
                              top: 4,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            // 1. AI Loader Row
            if (_isProcessingImage)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.aiInterpreting,
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            // 2. Title Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: context.l10n.title,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Smart Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: context.l10n.categoryAutoFilled,
                prefixIcon: const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isProcessingImage ? Colors.green : Colors.grey.shade400,
                    width: _isProcessingImage ? 2.0 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _categories.map((c) {
                return DropdownMenuItem(
                  value: c, 
                  child: Text(LocalizationHelpers.getCategory(context, c))
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),

            // 4. Description Field
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: context.l10n.description,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // 5. Condition Dropdown (Only for Donations)
            if (_type == 'Donate') ...[
              DropdownButtonFormField<String>(
                value: _condition,
                decoration: InputDecoration(
                  labelText: context.l10n.condition,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _conditions.map((c) {
                  return DropdownMenuItem(
                    value: c, 
                    child: Text(LocalizationHelpers.getCondition(context, c))
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _condition = val);
                },
              ),
              const SizedBox(height: 16),
            ],

            // 6. City Display
            TextField(
              controller: TextEditingController(text: LocalizationHelpers.getCity(context, _selectedCity)),
              decoration: InputDecoration(
                labelText: context.l10n.city,
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              readOnly: true,
              enabled: false,
            ),
            const SizedBox(height: 16),

            // 7. Location Picker Button
            ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
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
                }
              },
            ),
            const SizedBox(height: 32),

            // 8. Submit Button
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
