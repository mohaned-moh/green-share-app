import 'package:flutter/material.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/main.dart';
import 'package:green_share/models/feedback_model.dart';
import 'package:green_share/services/database_service.dart';

class FeedbackHubTab extends StatefulWidget {
  const FeedbackHubTab({super.key});

  @override
  State<FeedbackHubTab> createState() => _FeedbackHubTabState();
}

class _FeedbackHubTabState extends State<FeedbackHubTab> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FeedbackModel>>(
      stream: _databaseService.getAllFeedbackStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final feedbacks = snapshot.data ?? [];

        if (feedbacks.isEmpty) {
          return const Center(child: Text('No feedback yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final feedback = feedbacks[index];
            final isNew = feedback.status == 'New';

            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isNew ? Colors.orange : Colors.green,
                  child: Icon(
                    isNew ? Icons.new_releases : Icons.check_circle,
                    color: Colors.white,
                  ),
                ),
                title: Text(feedback.message),
                subtitle: Text('Status: ${isNew ? context.l10n.newFeedback : context.l10n.resolved}'),
                trailing: isNew
                    ? OutlinedButton(
                        onPressed: () async {
                          await _databaseService.updateFeedbackStatus(feedback.id, 'Resolved');
                        },
                        child: Text(context.l10n.markResolved),
                      )
                    : const Icon(Icons.check, color: Colors.green),
              ),
            );
          },
        );
      },
    );
  }
}

