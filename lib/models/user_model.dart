import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final DateTime createdAt;
  final int givenItemsCount;
  final int receivedItemsCount;
  final double averageRating;
  final int totalReviews;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.createdAt,
    this.givenItemsCount = 0,
    this.receivedItemsCount = 0,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'givenItemsCount': givenItemsCount,
      'receivedItemsCount': receivedItemsCount,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] != null ? DateTime.parse(map['createdAt'].toString()) : DateTime.now()),
      givenItemsCount: map['givenItemsCount'] ?? 0,
      receivedItemsCount: map['receivedItemsCount'] ?? 0,
      averageRating: map['averageRating'] != null ? (map['averageRating'] as num).toDouble() : 0.0,
      totalReviews: map['totalReviews'] ?? 0,
    );
  }
}
