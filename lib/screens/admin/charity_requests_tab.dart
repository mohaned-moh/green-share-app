import 'package:flutter/material.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/main.dart';
import 'package:green_share/models/user_model.dart';
import 'package:green_share/services/database_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class CharityRequestsTab extends StatelessWidget {
  const CharityRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: DatabaseService().getPendingCharitiesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(context.l10n.unexpectedError(snapshot.error.toString())));
        }

        final charities = snapshot.data ?? [];

        if (charities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 64, color: AppTheme.textSecondaryColor),
                const SizedBox(height: 16),
                Text(
                  context.l10n.noPendingRequests,
                  style: const TextStyle(fontSize: 18, color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: charities.length,
          itemBuilder: (context, index) {
            final charity = charities[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.amber,
                          child: Icon(Icons.business, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                charity.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                charity.email.isNotEmpty ? charity.email : 'No email provided',
                                style: const TextStyle(color: AppTheme.textSecondaryColor),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          timeago.format(charity.createdAt),
                          style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Phone: ${charity.phoneNumber ?? 'N/A'}'),
                    Text('${context.l10n.commercialRegistration}: ${charity.crNumber ?? 'N/A'}'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            try {
                              await DatabaseService().denyCharity(charity.id);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                              }
                            }
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: Text(context.l10n.deny, style: const TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await DatabaseService().approveCharity(charity.id);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                              }
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: Text(context.l10n.approve),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
