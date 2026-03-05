import 'package:flutter/material.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/screens/chat/chat_screen.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/models/chat_model.dart';
import 'package:green_share/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_share/main.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.messages)),
        body: Center(child: Text(context.l10n.pleaseLoginToViewMessages)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.messages)),
      body: StreamBuilder<List<ChatRoomModel>>(
        stream: _databaseService.getUserChatRooms(currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.noMessagesYet,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.connectWithOthers,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final chatRooms = snapshot.data!;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chat = chatRooms[index];
              final otherUserId = chat.participantIds.firstWhere((id) => id != currentUserId);

              // Need to fetch other user's info for name/avatar
              return FutureBuilder<UserModel?>(
                future: _databaseService.getUserProfile(otherUserId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox.shrink(); // Hide while loading
                  final otherUser = userSnapshot.data!;
                  final unreadCount = chat.unreadCounts[currentUserId] ?? 0;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                      backgroundImage: otherUser.profileImageUrl != null
                          ? NetworkImage(otherUser.profileImageUrl!)
                          : null,
                      child: otherUser.profileImageUrl == null
                          ? Text(
                              otherUser.name.isNotEmpty ? otherUser.name[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    title: Text(otherUser.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      chat.lastMessage ?? context.l10n.noMessagesYet,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(chat.updatedAt),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chat.id,
                            otherUserName: otherUser.name,
                            otherUserId: otherUser.id,
                            itemId: chat.itemId,
                          ),
                        ),
                      );
                    },
                  );
                }
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (dateTime.day == now.day) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    }
    if (difference.inDays == 1 && dateTime.day == now.subtract(const Duration(days: 1)).day) {
      return 'Yesterday';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
