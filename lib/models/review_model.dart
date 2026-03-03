import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String donorId;
  final String itemId;
  final double rating;
  final String comment;
  final DateTime timestamp;

  ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.donorId,
    required this.itemId,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'donorId': donorId,
      'itemId': itemId,
      'rating': rating,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ReviewModel.fromJson(Map<String, dynamic> map, String documentId) {
    return ReviewModel(
      id: documentId,
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? 'Anonymous',
      donorId: map['donorId'] ?? '',
      itemId: map['itemId'] ?? '',
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : 0.0,
      comment: map['comment'] ?? '',
      timestamp: map['timestamp'] is Timestamp 
          ? (map['timestamp'] as Timestamp).toDate()
          : (map['timestamp'] != null ? DateTime.parse(map['timestamp'].toString()) : DateTime.now()),
    );
  }
}
