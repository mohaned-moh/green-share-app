import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phoneNumber;
  final String? crNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final int givenItemsCount;
  final int receivedItemsCount;
  final double averageRating;
  final int totalReviews;
  final bool isBlocked;
  final bool isApproved;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.crNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.givenItemsCount = 0,
    this.receivedItemsCount = 0,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.isBlocked = false,
    this.isApproved = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'crNumber': crNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'givenItemsCount': givenItemsCount,
      'receivedItemsCount': receivedItemsCount,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'isBlocked': isBlocked,
      'isApproved': isApproved,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> map, String documentId) {
  // We create a temporary variable for the date to handle potential errors safely
  DateTime finalDate;
  
  try {
    finalDate = map['createdAt'] is Timestamp 
        ? (map['createdAt'] as Timestamp).toDate()
        : (map['createdAt'] != null ? DateTime.parse(map['createdAt'].toString()) : DateTime.now());
  } catch (e) {
    // If the manual entry in Firebase Console was formatted wrong, default to now instead of crashing
    finalDate = DateTime.now();
  }

  return UserModel(
    id: documentId,
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    role: map['role'] ?? 'User',
    phoneNumber: map['phoneNumber'],
    crNumber: map['crNumber'],
    profileImageUrl: map['profileImageUrl'],
    createdAt: finalDate, // Use the safely parsed date here
    givenItemsCount: map['givenItemsCount'] ?? 0,
    receivedItemsCount: map['receivedItemsCount'] ?? 0,
    averageRating: map['averageRating'] != null ? (map['averageRating'] as num).toDouble() : 0.0,
    totalReviews: map['totalReviews'] ?? 0,
    isBlocked: map['isBlocked'] ?? false,
    isApproved: map['isApproved'] ?? true,
  );
}
}
