import 'package:flutter/material.dart';
import 'package:green_share/screens/chat/chat_list_screen.dart';
import 'package:green_share/screens/home/home_screen.dart';
import 'package:green_share/screens/post/post_item_screen.dart';
import 'package:green_share/screens/profile/profile_screen.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/models/chat_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_share/main.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;
  final DatabaseService _databaseService = DatabaseService();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Widget _buildChatIcon(bool isSelected) {
    if (currentUserId == null) {
      return Icon(isSelected ? Icons.chat_bubble : Icons.chat_bubble_outline);
    }
    
    return StreamBuilder<List<ChatRoomModel>>(
      stream: _databaseService.getUserChatRooms(currentUserId!),
      builder: (context, snapshot) {
        int totalUnread = 0;
        if (snapshot.hasData) {
          for (var chat in snapshot.data!) {
            totalUnread += (chat.unreadCounts[currentUserId!] ?? 0);
          }
        }
        return Badge(
          isLabelVisible: totalUnread > 0,
          label: Text(totalUnread.toString()),
          child: Icon(isSelected ? Icons.chat_bubble : Icons.chat_bubble_outline),
        );
      },
    );
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const PostItemScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;

        if (isWideScreen) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  extended: true,
                  minExtendedWidth: 200,
                  destinations: [
                    NavigationRailDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: Text(context.l10n.home)),
                    NavigationRailDestination(icon: const Icon(Icons.add_circle_outline), selectedIcon: const Icon(Icons.add_circle), label: Text(context.l10n.post)),
                    NavigationRailDestination(icon: _buildChatIcon(false), selectedIcon: _buildChatIcon(true), label: Text(context.l10n.chat)),
                    NavigationRailDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: Text(context.l10n.profile)),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _screens[_currentIndex]),
              ],
            ),
          );
        }

        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: [
              NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: context.l10n.home),
              NavigationDestination(icon: const Icon(Icons.add_circle_outline), selectedIcon: const Icon(Icons.add_circle), label: context.l10n.post),
              NavigationDestination(icon: _buildChatIcon(false), selectedIcon: _buildChatIcon(true), label: context.l10n.chat),
              NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: context.l10n.profile),
            ],
          ),
        );
      },
    );
  }
}

