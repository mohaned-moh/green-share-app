import 'package:flutter/material.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/models/chat_model.dart';
import 'package:green_share/models/item_model.dart';
import 'package:green_share/models/review_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:green_share/main.dart';
import 'package:green_share/screens/profile/profile_screen.dart';
import 'package:green_share/widgets/transaction_card.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String otherUserId;
  final String? itemId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.otherUserId,
    this.itemId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  ItemModel? _linkedItem;
  StreamSubscription<ItemModel?>? _itemSubscription;

  @override
  void initState() {
    super.initState();
    _resetUnread();
    _listenToLinkedItem();
  }

  void _listenToLinkedItem() {
    if (widget.itemId != null) {
      _itemSubscription = _databaseService.getItemStream(widget.itemId!).listen((item) {
        if (mounted) {
          setState(() {
            _linkedItem = item;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _itemSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _resetUnread() {
    if (currentUserId != null) {
      _databaseService.resetUnreadCount(widget.chatId, currentUserId!);
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || currentUserId == null) return;
    
    _messageController.clear();
    await _databaseService.sendMessage(widget.chatId, currentUserId!, widget.otherUserId, text);
    _resetUnread();
  }

  @override
  Widget build(BuildContext context) {
    final bool canAwardItem = _linkedItem != null && 
                              currentUserId != null &&
                              ((_linkedItem!.type == 'Donate' && _linkedItem!.ownerId == currentUserId) ||
                               (_linkedItem!.type == 'Request' && _linkedItem!.ownerId != currentUserId)) &&
                              _linkedItem!.status == 'available';

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: widget.otherUserId),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.otherUserName),
              const SizedBox(width: 8),
              const Icon(Icons.info_outline, size: 18),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (currentUserId != null)
            TransactionCard(currentUserId: currentUserId!),
          if (canAwardItem)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.eco, color: Colors.green, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ready to share?', 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.giveItemTo(_linkedItem!.title, widget.otherUserName),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _awardItem(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Award', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: currentUserId == null 
              ? Center(child: Text(context.l10n.pleaseLoginToSendMessages))
              : StreamBuilder<List<MessageModel>>(
                  stream: _databaseService.getChatMessages(widget.chatId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mark_chat_unread_outlined, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              context.l10n.startTheConversation,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.sayHiTo(widget.otherUserName),
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }

                    final messages = snapshot.data!;
                    
                    if (messages.isNotEmpty && currentUserId != null) {
                      Future.microtask(() => _resetUnread());
                    }

                    return ListView.builder(
                      reverse: true, // Scroll to bottom naturally and build up
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == currentUserId;
                        
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? AppTheme.primaryColor : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: context.l10n.typeMessage,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _awardItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_linkedItem!.type == 'Donate' ? context.l10n.donateItemQ : context.l10n.markRequestCompletedQ),
        content: Text(
          _linkedItem!.type == 'Donate' 
            ? context.l10n.confirmDonate(widget.otherUserName)
            : context.l10n.confirmComplete(widget.otherUserName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.itemAwarded)),
              );

              // Background operations
              () async {
                try {
                  // The receiverId is always the other person involved in the chat, 
                  // regardless of who is donating or requesting.
                  final interactionReceiverId = widget.otherUserId;
                  
                  // Update item status to pending
                  await _databaseService.updateItemStatus(_linkedItem!.id, 'pending', receiverId: interactionReceiverId);
                  
                  // Increment stats for both users
                  // If Donate: owner gave, interactionReceiverId received.
                  // If Request: owner received, interactionReceiverId gave.
                  await _databaseService.incrementAwardStats(
                    ownerId: _linkedItem!.ownerId, 
                    recipientId: interactionReceiverId,
                    itemType: _linkedItem!.type,
                  );
                  
                  // Send automated message
                  final automatedMessage = _linkedItem!.type == 'Donate'
                      ? context.l10n.automatedDonateMsg
                      : context.l10n.automatedCompleteMsg;
                      
                  await _databaseService.sendMessage(widget.chatId, currentUserId!, widget.otherUserId, automatedMessage);
                  
                  // Refresh handled by stream
                } catch (e) {
                  print('Error awarding item: $e');
                }
              }();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(context.l10n.yesConfirm),
          ),
        ],
      ),
    );
  }
}
