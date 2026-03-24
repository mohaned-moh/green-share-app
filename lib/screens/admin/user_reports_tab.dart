import 'package:flutter/material.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/main.dart';
import 'package:green_share/models/report_model.dart';
import 'package:green_share/services/database_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserReportsTab extends StatelessWidget {
  const UserReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReportModel>>(
      stream: DatabaseService().getAllReportsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(context.l10n.unexpectedError(snapshot.error.toString())));
        }

        final reports = snapshot.data ?? [];

        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.outlined_flag, size: 64, color: AppTheme.textSecondaryColor),
                const SizedBox(height: 16),
                Text(
                  context.l10n.noPendingRequests, // We'll just reuse a generic empty text
                  style: const TextStyle(fontSize: 18, color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final isResolved = report.status == 'Resolved';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isResolved ? Colors.green.shade200 : Colors.red.shade200,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isResolved ? Icons.check_circle : Icons.flag,
                              color: isResolved ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isResolved ? context.l10n.resolved : context.l10n.newFeedback,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isResolved ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          timeago.format(report.createdAt),
                          style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${context.l10n.reporter}: ${report.reporterName}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${context.l10n.reportedUser}: ${report.reportedUserName}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      report.reason,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    if (!isResolved)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            try {
                              await DatabaseService().updateReportStatus(report.id, 'Resolved');
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.check, color: Colors.green),
                          label: Text(
                            context.l10n.markResolved,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
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
