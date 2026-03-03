import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
      'isRead': isRead,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> map, String documentId) {
    return MessageModel(
      id: documentId,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      sentAt: map['sentAt'] is Timestamp
          ? (map['sentAt'] as Timestamp).toDate()
          : (map['sentAt'] != null ? DateTime.parse(map['sentAt'].toString()) : DateTime.now()),
      isRead: map['isRead'] ?? false,
    );
  }
}

class ChatRoomModel {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime updatedAt;
  final Map<String, int> unreadCounts;
  final String? itemId;

  ChatRoomModel({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    required this.updatedAt,
    required this.unreadCounts,
    this.itemId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'unreadCounts': unreadCounts,
      'itemId': itemId,
    };
  }

  factory ChatRoomModel.fromJson(Map<String, dynamic> map, String documentId) {
    return ChatRoomModel(
      id: documentId,
      participantIds: List<String>.from(map['participantIds'] ?? []),
      lastMessage: map['lastMessage'],
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : (map['updatedAt'] != null ? DateTime.parse(map['updatedAt'].toString()) : DateTime.now()),
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
      itemId: map['itemId'],
    );
  }
}
