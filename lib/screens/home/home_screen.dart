import 'package:flutter/material.dart';
import 'package:green_share/widgets/item_card.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/models/item_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:green_share/screens/home/item_details_screen.dart';

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
          const SnackBar(content: Text('Location services are disabled. Please enable GPS in your device to view nearby items.')),
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
            const SnackBar(content: Text('Location permission denied. Please allow location access to view nearby items.')),
          );
          setState(() => _isLoadingLocation = false);
        }
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied. Please enable them in your device settings to view nearby items.')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get current location. Please try manually moving the map.')),
        );
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'List'),
              Tab(icon: Icon(Icons.map), text: 'Map'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // Show filter dialog
              },
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
                decoration: const InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ItemModel>>(
                stream: _databaseService.getItemsStream(searchQuery: _searchQuery),
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
                                  const Text(
                                    'No items found',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Be the first to post a donation or request!',
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
