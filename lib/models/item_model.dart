import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'Donate' or 'Request'
  final String category;
  final String condition;
  final List<String> imageUrls;
  final String ownerId;
  final DateTime postedAt;
  final String status; // 'available', 'claimed', 'completed'
  final String location;
  final String city;
  final double? latitude;
  final double? longitude;
  final String? receiverId; // Added to track who received the item
  final bool hasBeenRated;  // Track if a review has already been submitted
  final bool isOwnerBlocked;

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.condition,
    required this.imageUrls,
    required this.ownerId,
    required this.postedAt,
    this.status = 'available',
    required this.location,
    required this.city,
    this.latitude,
    this.longitude,
    this.receiverId,
    this.hasBeenRated = false,
    this.isOwnerBlocked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'condition': condition,
      'imageUrls': imageUrls,
      'ownerId': ownerId,
      'postedAt': Timestamp.fromDate(postedAt),
      'status': status,
      'location': location,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'receiverId': receiverId,
      'hasBeenRated': hasBeenRated,
      'isOwnerBlocked': isOwnerBlocked,
    };
  }

  factory ItemModel.fromJson(Map<String, dynamic> map, String documentId) {
    return ItemModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'Donate',
      category: map['category'] ?? 'Other',
      condition: map['condition'] ?? 'Good',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      ownerId: map['ownerId'] ?? '',
      postedAt: map['postedAt'] is Timestamp 
          ? (map['postedAt'] as Timestamp).toDate()
          : (map['postedAt'] != null ? DateTime.parse(map['postedAt'].toString()) : DateTime.now()),
      status: map['status'] ?? 'available',
      location: map['location'] ?? 'Unknown location',
      city: map['city'] ?? 'Unknown city',
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      receiverId: map['receiverId'],
      hasBeenRated: map['hasBeenRated'] ?? false,
      isOwnerBlocked: map['isOwnerBlocked'] ?? false,
    );
  }
}
