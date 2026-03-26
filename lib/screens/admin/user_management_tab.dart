import 'package:flutter/material.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/main.dart';
import 'package:green_share/models/user_model.dart';
import 'package:green_share/services/database_service.dart';

class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final DatabaseService _databaseService = DatabaseService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: context.l10n.searchByNameOrId,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: _databaseService.getAllUsersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final allUsers = snapshot.data ?? [];
              
              final users = _searchQuery.isEmpty 
                  ? allUsers 
                  : allUsers.where((user) {
                      final nameMatches = user.name.toLowerCase().contains(_searchQuery);
                      final idMatches = user.id.toLowerCase().contains(_searchQuery);
                      return nameMatches || idMatches;
                    }).toList();

              if (users.isEmpty && allUsers.isNotEmpty) {
                return const Center(child: Text('No users match your search.'));
              } else if (users.isEmpty) {
                return const Center(child: Text('No users found.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isAdmin = user.role == 'admin';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isAdmin ? Colors.amber : AppTheme.primaryColor,
                        child: Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${user.email}\nID: ${user.id}\nRole: ${user.role}'),
                      isThreeLine: true,
                      trailing: isAdmin 
                          ? const SizedBox.shrink() 
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: user.isBlocked ? AppTheme.primaryColor : Colors.red,
                              ),
                              onPressed: () async {
                                await _databaseService.updateUserBlockStatus(user.id, !user.isBlocked);
                              },
                              child: Text(user.isBlocked ? context.l10n.unblockUser : context.l10n.blockUser),
                            ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

