import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final String message;
  final String status; // 'New', 'Resolved'
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.message,
    this.status = 'New',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory FeedbackModel.fromJson(Map<String, dynamic> map, String documentId) {
    return FeedbackModel(
      id: documentId,
      userId: map['userId'] ?? '',
      message: map['message'] ?? '',
      status: map['status'] ?? 'New',
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] != null ? DateTime.parse(map['createdAt'].toString()) : DateTime.now()),
    );
  }
}
