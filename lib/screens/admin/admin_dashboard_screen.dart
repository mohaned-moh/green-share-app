import 'package:flutter/material.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/main.dart';
import 'package:green_share/screens/admin/data_center_tab.dart';
import 'package:green_share/screens/admin/user_management_tab.dart';
import 'package:green_share/screens/admin/feedback_hub_tab.dart';
import 'package:green_share/screens/admin/global_activity_tab.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.adminDashboard),
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: [
              Tab(text: context.l10n.dataCenter, icon: const Icon(Icons.analytics)),
              Tab(text: context.l10n.userManagement, icon: const Icon(Icons.people)),
              Tab(text: context.l10n.feedbackHub, icon: const Icon(Icons.feedback)),
              Tab(text: context.l10n.globalActivity, icon: const Icon(Icons.public)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DataCenterTab(),
            UserManagementTab(),
            FeedbackHubTab(),
            GlobalActivityTab(),
          ],
        ),
      ),
    );
  }
}
