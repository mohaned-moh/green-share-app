import 'package:flutter/material.dart';
import 'package:green_share/widgets/item_card.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/models/item_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:green_share/screens/home/item_details_screen.dart';
import 'package:green_share/main.dart'; // import context extension

import 'package:flutter/foundation.dart' show kIsWeb;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String _searchQuery = '';
  final MapController _mapController = MapController();
  LatLng _mapCenter = const LatLng(0, 0);
  bool _isLoadingLocation = true;
  
  String? _selectedCategory;
  String? _selectedCity;
  String? _selectedCondition;

  final List<String> _categories = [
    'All',
    'Clothing',
    'Furniture',
    'Books',
    'Electronics',
    'Toys',
    'Other'
  ];

  final List<String> _cities = [
    'All',
    'Amman',
    'Zarqa',
    'Irbid',
    'Aqaba',
    'Mafraq',
    'Jerash',
    'Madaba',
    'Other'
  ];

  final List<String> _conditions = [
    'All',
    'New',
    'Good',
    'Fair',
    'Poor'
  ];

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.l10n.filterOptions ?? 'Filter Options', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory ?? 'All',
                    decoration: InputDecoration(labelText: context.l10n.categoryAutoFilled),
                    items: _categories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        _selectedCategory = val == 'All' ? null : val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCity ?? 'All',
                    decoration: InputDecoration(labelText: context.l10n.city),
                    items: _cities.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        _selectedCity = val == 'All' ? null : val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCondition ?? 'All',
                    decoration: InputDecoration(labelText: context.l10n.condition),
                    items: _conditions.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        _selectedCondition = val == 'All' ? null : val;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {}); // Trigger stream rebuild with new filters
                    },
                    child: Text(context.l10n.applyFilters ?? 'Apply Filters'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
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
      
      final currentLatLng = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _mapCenter = currentLatLng;
          _isLoadingLocation = false;
        });
        _mapController.move(currentLatLng, 12.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
        // Delay the failure banner by 8 seconds as requested
        Future.delayed(const Duration(seconds: 8), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.locationFailed)),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.discover),
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.list), text: context.l10n.list),
              Tab(icon: const Icon(Icons.map), text: context.l10n.map),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: context.l10n.searchItems,
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ItemModel>>(
                stream: _databaseService.getItemsStream(
                  searchQuery: _searchQuery,
                  category: _selectedCategory,
                  city: _selectedCity,
                  condition: _selectedCondition,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    print('HomeScreen Stream Error: ${snapshot.error}');
                  }

                  final items = snapshot.data ?? [];
                  
                  // Filter items that have valid coordinates for the map
                  final mapItems = items.where((item) => item.latitude != null && item.longitude != null).toList();

                  return TabBarView(
                    children: [
                      // List View Tab
                      items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.eco_outlined, size: 60, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.l10n.noItemsFound,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    context.l10n.beTheFirst,
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                childAspectRatio: 0.85, // Adjust based on ItemCard contents
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return ItemCard(item: items[index]);
                              },
                            ),
                      
                      // Map View Tab
                      Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _mapCenter,
                              initialZoom: 4.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.greenshare',
                              ),
                              MarkerLayer(
                                markers: mapItems.map((item) {
                                  return Marker(
                                    point: LatLng(item.latitude!, item.longitude!),
                                    width: 40,
                                    height: 40,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ItemDetailsScreen(item: item),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.location_pin,
                                        color: item.type == 'Donate' ? Colors.green : Colors.orange,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          if (_isLoadingLocation)
                            const Center(child: CircularProgressIndicator()),
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: FloatingActionButton(
                              heroTag: 'home_map_location',
                              onPressed: _determinePosition,
                              child: const Icon(Icons.my_location),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
