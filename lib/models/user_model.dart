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
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'User',
      phoneNumber: map['phoneNumber'],
      crNumber: map['crNumber'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] != null ? DateTime.parse(map['createdAt'].toString()) : DateTime.now()),
      givenItemsCount: map['givenItemsCount'] ?? 0,
      receivedItemsCount: map['receivedItemsCount'] ?? 0,
      averageRating: map['averageRating'] != null ? (map['averageRating'] as num).toDouble() : 0.0,
      totalReviews: map['totalReviews'] ?? 0,
      isBlocked: map['isBlocked'] ?? false,
    );
  }
}
