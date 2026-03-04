import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_share/models/item_model.dart';
import 'package:green_share/models/user_model.dart';
import 'package:green_share/models/chat_model.dart';
import 'package:green_share/models/review_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Users ---

  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // --- Items ---

  Future<String> addItem(ItemModel item) async {
    final docRef = await _firestore.collection('items').add(item.toJson());
    // Update the item with its generated ID
    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  Future<ItemModel?> getItemById(String itemId) async {
    final doc = await _firestore.collection('items').doc(itemId).get();
    if (doc.exists && doc.data() != null) {
      return ItemModel.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> updateItemStatus(String itemId, String status, {String? receiverId}) async {
    final data = <String, dynamic>{'status': status};
    if (receiverId != null) {
      data['receiverId'] = receiverId;
    }
    await _firestore.collection('items').doc(itemId).update(data);
  }

  Future<void> incrementAwardStats({required String ownerId, String? recipientId, required String itemType}) async {
    if (itemType == 'Donate') {
      // Owner gave the item
      await _firestore.collection('users').doc(ownerId).update({
        'givenItemsCount': FieldValue.increment(1)
      });
      // Recipient received the item
      if (recipientId != null) {
        await _firestore.collection('users').doc(recipientId).update({
          'receivedItemsCount': FieldValue.increment(1)
        });
      }
    } else if (itemType == 'Request') {
      // Owner's request was fulfilled (they received)
      await _firestore.collection('users').doc(ownerId).update({
        'receivedItemsCount': FieldValue.increment(1)
      });
      // Recipient fulfilled the owner's request (they gave)
      if (recipientId != null) {
        await _firestore.collection('users').doc(recipientId).update({
          'givenItemsCount': FieldValue.increment(1)
        });
      }
    }
  }

  Stream<List<ItemModel>> getItemsStream({String? category, String? searchQuery}) {
    Query query = _firestore.collection('items');
    
    // Default filter for available items
    query = query.where('status', isEqualTo: 'available')
                 .orderBy('postedAt', descending: true);

    return query.snapshots().map((snapshot) {
      var items = snapshot.docs.map((doc) => ItemModel.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
      
      // Client-side filtering for category and search
      if (category != null && category != 'All') {
        items = items.where((item) => item.category == category).toList();
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final queryLower = searchQuery.toLowerCase();
        items = items.where((item) => 
          item.title.toLowerCase().contains(queryLower) || 
          item.description.toLowerCase().contains(queryLower)
        ).toList();
      }
      
      return items;
    });
  }
  
  Stream<List<ItemModel>> getUserItemsStream(String userId) {
    return _firestore
        .collection('items')
        .where('ownerId', isEqualTo: userId)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ItemModel.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Stream<List<ItemModel>> getTransactionHistoryStream({required String userId, required bool isDonated}) {
    if (isDonated) {
      // Items the user posted that are no longer available (e.g. status == 'donated' or 'awarded')
      // Note: If you have a specific status for given items, update 'donated' to that status.
      return _firestore
          .collection('items')
          .where('ownerId', isEqualTo: userId)
          .where('status', isEqualTo: 'donated') // Assuming 'donated' is the status
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ItemModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
              .toList());
    } else {
      // Items the user received. This requires the item document to store `receiverId` 
      // or similar when awarded.
      return _firestore
          .collection('items')
          .where('receiverId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ItemModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
              .toList());
    }
  }

  // --- Storage ---

  Future<String?> uploadImage(File imageFile, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // --- Chats ---

  Future<String> createOrGetChatRoom(String userId1, String userId2, {String? itemId}) async {
    // Determine a consistent chat ID based on user IDs
    // We append itemId to the chatId if it exists, so distinct items have distinct chat rooms between the same users
    final List<String> sortedIds = [userId1, userId2]..sort();
    String chatId = '${sortedIds[0]}_${sortedIds[1]}';
    if (itemId != null) {
      chatId += '_$itemId';
    }

    final docRef = _firestore.collection('chats').doc(chatId);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      final newChat = ChatRoomModel(
        id: chatId,
        participantIds: sortedIds,
        updatedAt: DateTime.now(),
        unreadCounts: {userId1: 0, userId2: 0},
        itemId: itemId,
      );
      await docRef.set(newChat.toJson());
    }
    return chatId;
  }

  Stream<List<ChatRoomModel>> getUserChatRooms(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoomModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage(String chatId, String senderId, String recipientId, String text) async {
    // Add message with server timestamp
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Update chat room last message & time
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
      'unreadCounts.$recipientId': FieldValue.increment(1),
    });
  }

  Future<void> resetUnreadCount(String chatId, String userId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCounts.$userId': 0,
    });
  }

  // --- Reviews ---

  Future<void> addReview(ReviewModel review) async {
    // 1. Add review to donor's subcollection
    final reviewRef = _firestore
        .collection('users')
        .doc(review.donorId)
        .collection('reviews')
        .doc();
    
    final reviewData = review.toJson();
    reviewData['id'] = reviewRef.id;
    await reviewRef.set(reviewData);

    // 2. Mark item as rated
    await _firestore.collection('items').doc(review.itemId).update({
      'hasBeenRated': true,
    });

    // 3. Recalculate and update Donor's average rating
    final donorDoc = await _firestore.collection('users').doc(review.donorId).get();
    if (donorDoc.exists) {
      final data = donorDoc.data()!;
      int currentTotalReviews = data['totalReviews'] ?? 0;
      double currentAverageRating = data['averageRating'] != null 
          ? (data['averageRating'] as num).toDouble() 
          : 0.0;
      
      double newTotalRatingScore = (currentAverageRating * currentTotalReviews) + review.rating;
      int newTotalReviews = currentTotalReviews + 1;
      double newAverageRating = newTotalRatingScore / newTotalReviews;

      await _firestore.collection('users').doc(review.donorId).update({
        'averageRating': newAverageRating,
        'totalReviews': newTotalReviews,
      });
    }
  }

  Stream<List<ReviewModel>> getUserReviewsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}
