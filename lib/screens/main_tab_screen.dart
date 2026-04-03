import 'package:flutter/material.dart';
import 'package:green_share/screens/chat/chat_list_screen.dart';
import 'package:green_share/screens/home/home_screen.dart';
import 'package:green_share/screens/post/post_item_screen.dart';
import 'package:green_share/screens/profile/profile_screen.dart';
import 'package:green_share/screens/admin/admin_dashboard_screen.dart';
import 'package:green_share/screens/admin/admin_archive_screen.dart';
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
  bool _isAdmin = false;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    try {
      if (currentUserId != null) {
        // Retry logic for fresh signups
        dynamic user;
        int retries = 0;
        while (retries < 3) {
          user = await _databaseService.getUserProfile(currentUserId!);
          if (user != null) break;
          await Future.delayed(const Duration(seconds: 1)); // Wait for propagates
          retries++;
        }
        
        if (mounted) {
          setState(() {
            _isAdmin = user?.role == 'admin';
            _isLoadingRole = false; 
          });

          if (user == null) {
            await FirebaseAuth.instance.signOut();
          }
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingRole = false);
        }
      }
    } catch (e) {
      // If there is ANY error (like a network issue), stop the loading spinner
      if (mounted) {
        setState(() => _isLoadingRole = false);
      }
      debugPrint("Error checking admin role: $e");
    }
  }

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

  List<Widget> get _screens {
    final screens = <Widget>[
      const HomeScreen(),
      _isAdmin ? const AdminArchiveScreen() : const PostItemScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];
    if (_isAdmin) {
      screens.insert(3, const AdminDashboardScreen());
    }
    return screens;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;

        if (isWideScreen) {
          final railDests = <NavigationRailDestination>[
            NavigationRailDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: Text(context.l10n.home)),
            _isAdmin
                ? NavigationRailDestination(icon: const Icon(Icons.archive_outlined), selectedIcon: const Icon(Icons.archive), label: Text(context.l10n.archive))
                : NavigationRailDestination(icon: const Icon(Icons.add_circle_outline), selectedIcon: const Icon(Icons.add_circle), label: Text(context.l10n.post)),
            NavigationRailDestination(icon: _buildChatIcon(false), selectedIcon: _buildChatIcon(true), label: Text(context.l10n.chat)),
            if (_isAdmin)
              NavigationRailDestination(icon: const Icon(Icons.admin_panel_settings_outlined), selectedIcon: const Icon(Icons.admin_panel_settings), label: Text(context.l10n.adminDashboard)),
            NavigationRailDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: Text(context.l10n.profile)),
          ];

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
                  destinations: railDests,
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _screens[_currentIndex]),
              ],
            ),
          );
        }

        final navDests = <NavigationDestination>[
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: context.l10n.home),
          _isAdmin
              ? NavigationDestination(icon: const Icon(Icons.archive_outlined), selectedIcon: const Icon(Icons.archive), label: context.l10n.archive)
              : NavigationDestination(icon: const Icon(Icons.add_circle_outline), selectedIcon: const Icon(Icons.add_circle), label: context.l10n.post),
          NavigationDestination(icon: _buildChatIcon(false), selectedIcon: _buildChatIcon(true), label: context.l10n.chat),
          if (_isAdmin)
            NavigationDestination(icon: const Icon(Icons.admin_panel_settings_outlined), selectedIcon: const Icon(Icons.admin_panel_settings), label: context.l10n.adminDashboard),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: context.l10n.profile),
        ];

        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: navDests,
          ),
        );
      },
    );
  }
}
