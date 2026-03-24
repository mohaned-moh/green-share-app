import 'package:flutter/material.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/main.dart';
import 'package:green_share/models/feedback_model.dart';
import 'package:green_share/models/report_model.dart';
import 'package:green_share/models/user_model.dart';
import 'package:green_share/services/database_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminArchiveScreen extends StatelessWidget {
  const AdminArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.archive),
          bottom: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: [
              Tab(text: context.l10n.archivedRequests, icon: const Icon(Icons.history)),
              Tab(text: context.l10n.resolvedFeedback, icon: const Icon(Icons.feedback_outlined)),
              Tab(text: context.l10n.resolvedReports, icon: const Icon(Icons.gavel_outlined)),
              Tab(text: context.l10n.blockedUsers, icon: const Icon(Icons.block)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ArchivedRequestsView(),
            _ResolvedFeedbackView(),
            _ResolvedReportsView(),
            _BlockedUsersView(),
          ],
        ),
      ),
    );
  }
}

class _ArchivedRequestsView extends StatelessWidget {
  const _ArchivedRequestsView();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: DatabaseService().getArchivedRequestsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return const Center(child: Text('No archived requests.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final user = requests[index];
            // Accessing the dynamic status we saved to the JSON
            final rawJson = user.toJson(); 
            // Workaround since 'status' is not a dedicated BaseModel field
            // But actually we can pass the snapshot doc.data() and assume 'status' is there but we parsed it using fromJson, which drops 'status' if it's not a field.
            // Wait, we need to read 'status' from the raw dataset, maybe we should just rely on user.isApproved for the UI.
            final isApproved = user.isApproved;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: isApproved ? Colors.green.shade200 : Colors.red.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  isApproved ? Icons.check_circle : Icons.cancel,
                  color: isApproved ? Colors.green : Colors.red,
                  size: 32,
                ),
                title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${user.email}\nCR: ${user.crNumber ?? "N/A"}'),
                trailing: Text(
                  isApproved ? context.l10n.approved : context.l10n.rejected,
                  style: TextStyle(
                    color: isApproved ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}

class _ResolvedFeedbackView extends StatelessWidget {
  const _ResolvedFeedbackView();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FeedbackModel>>(
      stream: DatabaseService().getResolvedFeedbackStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final feedback = snapshot.data ?? [];
        if (feedback.isEmpty) {
          return const Center(child: Text('No resolved feedback.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: feedback.length,
          itemBuilder: (context, index) {
            final f = feedback[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.task_alt, color: Colors.green),
                title: Text(f.message),
                subtitle: Text(timeago.format(f.createdAt)),
                trailing: const Icon(Icons.check, color: Colors.green),
              ),
            );
          },
        );
      },
    );
  }
}

class _ResolvedReportsView extends StatelessWidget {
  const _ResolvedReportsView();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReportModel>>(
      stream: DatabaseService().getResolvedReportsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return const Center(child: Text('No resolved reports.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final r = reports[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.gavel, color: Colors.green),
                title: Text('${context.l10n.reporter}: ${r.reporterName} \n${context.l10n.reportedUser}: ${r.reportedUserName}'),
                subtitle: Text('${r.reason}\n${timeago.format(r.createdAt)}'),
                trailing: const Icon(Icons.check, color: Colors.green),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}

class _BlockedUsersView extends StatelessWidget {
  const _BlockedUsersView();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: DatabaseService().getBlockedUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('No blocked users.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.block, color: Colors.red, size: 32),
                title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${user.email}\n${user.role}'),
                trailing: TextButton.icon(
                  onPressed: () async {
                    try {
                      await DatabaseService().updateUserBlockStatus(user.id, false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${user.name} has been unblocked.')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.settings_backup_restore, color: Colors.green),
                  label: const Text('Unblock', style: TextStyle(color: Colors.green)),
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
