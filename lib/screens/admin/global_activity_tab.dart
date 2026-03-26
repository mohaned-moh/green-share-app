import 'package:flutter/material.dart';
import 'package:green_share/main.dart';
import 'package:green_share/models/item_model.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:green_share/models/user_model.dart';

class GlobalActivityTab extends StatefulWidget {
  const GlobalActivityTab({super.key});

  @override
  State<GlobalActivityTab> createState() => _GlobalActivityTabState();
}

class _GlobalActivityTabState extends State<GlobalActivityTab> {
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
              labelText: context.l10n.searchByItemName,
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
          child: StreamBuilder<List<ItemModel>>(
      stream: _databaseService.getGlobalActivityStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allItems = snapshot.data ?? [];
        
        final items = _searchQuery.isEmpty 
            ? allItems 
            : allItems.where((item) {
                return item.title.toLowerCase().contains(_searchQuery);
              }).toList();

        if (items.isEmpty && allItems.isNotEmpty) {
          return const Center(child: Text('No activities match your search.'));
        } else if (items.isEmpty) {
          return const Center(child: Text('No activity yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isDonation = item.type == 'Donate';

            return FutureBuilder(
              future: Future.wait([
                _databaseService.getUserProfile(item.ownerId),
                if (item.receiverId != null && item.receiverId!.isNotEmpty)
                  _databaseService.getUserProfile(item.receiverId!),
              ]),
              builder: (context, userSnapshot) {
                final results = userSnapshot.data as List?;
                final owner = results != null && results.isNotEmpty ? results[0] as UserModel? : null;
                final receiver = results != null && results.length > 1 ? results[1] as UserModel? : null;

                String subtitleText = '${isDonation ? context.l10n.donate : context.l10n.request} • Status: ${item.status}\n';
                if (owner != null) {
                  subtitleText += 'By ${owner.name}';
                } else {
                  subtitleText += 'By ${item.ownerId.length > 5 ? item.ownerId.substring(0, 5) : item.ownerId}...';
                }

                if (receiver != null) {
                  subtitleText += ' → To ${receiver.name}';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isDonation ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                      child: Icon(
                        isDonation ? Icons.volunteer_activism : Icons.waving_hand,
                        color: isDonation ? Colors.green : Colors.blue,
                      ),
                    ),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(subtitleText),
                    isThreeLine: true,
                    onTap: () => _showTransactionDetails(context, item),
                    trailing: Text(
                      timeago.format(item.postedAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    ),
    ),
    ],
    );
  }

  void _showTransactionDetails(BuildContext context, ItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return FutureBuilder(
              future: Future.wait([
                _databaseService.getUserProfile(item.ownerId),
                if (item.receiverId != null && item.receiverId!.isNotEmpty) _databaseService.getUserProfile(item.receiverId!),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final results = snapshot.hasError ? null : snapshot.data as List?;
                final owner = results != null && results.isNotEmpty ? results[0] as UserModel? : null;
                final receiver = results != null && results.length > 1 ? results[1] as UserModel? : null;

                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.type,
                            style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.status.toUpperCase(),
                            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Description'),
                      subtitle: Text(item.description.isNotEmpty ? item.description : 'No description provided.'),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Owner'),
                      subtitle: Text(owner != null ? owner.name : item.ownerId),
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                    ),
                    if (item.receiverId != null && item.receiverId!.isNotEmpty) ...[
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Receiver'),
                        subtitle: Text(receiver != null ? receiver.name : item.receiverId!),
                        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                      ),
                    ],
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Location'),
                      subtitle: Text('${item.city}, ${item.location}'),
                      leading: const Icon(Icons.location_on, color: Colors.grey),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Posted At'),
                      subtitle: Text(timeago.format(item.postedAt)),
                      leading: const Icon(Icons.access_time, color: Colors.grey),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

