import 'package:flutter/material.dart';
import 'package:green_share/main.dart';
import 'package:green_share/models/item_model.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class GlobalActivityTab extends StatefulWidget {
  const GlobalActivityTab({super.key});

  @override
  State<GlobalActivityTab> createState() => _GlobalActivityTabState();
}

class _GlobalActivityTabState extends State<GlobalActivityTab> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ItemModel>>(
      stream: _databaseService.getGlobalActivityStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const Center(child: Text('No activity yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isDonation = item.type == 'Donate';

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
                subtitle: Text('${isDonation ? context.l10n.donate : context.l10n.request} • Status: ${item.status}\nBy ${item.ownerId.substring(0, 5)}...'),
                isThreeLine: true,
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
  }
}

