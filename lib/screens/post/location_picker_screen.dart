import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _selectedLocation;
  String? _cityName;
  final MapController _mapController = MapController();
  bool _isLoadingLocation = true;
  bool _isFetchingCity = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _fetchCityName(LatLng point) async {
    setState(() {
      _isFetchingCity = true;
      _cityName = null;
    });
    
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=10&addressdetails=1');
      final response = await http.get(url, headers: {'User-Agent': 'GreenShareApp'});
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          String? city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? address['state'];
          if (mounted) {
            setState(() {
              _cityName = city;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching city: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingCity = false;
        });
      }
    }
  }

  Future<void> _determinePosition() async {
    setState(() => _isLoadingLocation = true);
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled. Please enable GPS in your device to post an item.')),
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
            const SnackBar(content: Text('Location permission denied. Please allow location access to post an item.')),
          );
          setState(() => _isLoadingLocation = false);
        }
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied. Please enable them in your device settings to post an item.')),
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
          _selectedLocation = currentLatLng;
          _isLoadingLocation = false;
        });
        _fetchCityName(currentLatLng);
        // Move the camera smoothly to the fetched position
        // Since flutter_map v6+, move is standard; for explicit animation, external plugins are needed.
        // `move` accomplishes the jump natively.
        _mapController.move(currentLatLng, 15.0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get current location. Please try again or manually select a location.')),
        );
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(0, 0),
              initialZoom: 2.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
                _fetchCityName(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.greenshare',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_isLoadingLocation)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_isFetchingCity)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 16),
                      Text('Identifying City...'),
                    ],
                  ),
                ),
              ),
            ),
          if (!_isFetchingCity && _cityName != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_city, color: Colors.green),
                      const SizedBox(width: 16),
                      Text('City detected: $_cityName', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'my_location_picker',
              onPressed: _determinePosition,
              child: const Icon(Icons.my_location),
            ),
          ),
          if (_selectedLocation != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 90,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isFetchingCity ? null : () {
                  Navigator.of(context).pop({
                    'location': _selectedLocation,
                    'city': _cityName,
                  });
                },
                child: const Text('Confirm Location', style: TextStyle(fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }
}
