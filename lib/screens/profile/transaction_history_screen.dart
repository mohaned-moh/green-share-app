import 'package:flutter/material.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/models/item_model.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/widgets/item_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction History')),
        body: const Center(child: Text('Please log in to view history.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Donated'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(isDonated: true),
          _buildTransactionList(isDonated: false),
        ],
      ),
    );
  }

  Widget _buildTransactionList({required bool isDonated}) {
    // We need a stream that fetches items where the current user is either the owner (donated)
    // or the receiver (received). Since we don't have a direct 'receivedBy' field yet, 
    // a common approach for donations is item.ownerId == currentUserId && item.status == 'donated'
    // For received, we'd need another query or way to track it.
    
    // For now, let's use the standard `getUserItemsStream` but filter by status.
    // If the database doesn't explicitly store who received an item, we will show
    // the items the user has given away under "Donated". 
    
    return StreamBuilder<List<ItemModel>>(
      // We will only query history. 
      // Donated: items I own where status is "donated" (or "awarded" whatever status you use).
      // Received: This requires the db to have `recipientId`. We might need to adjust the query.
      stream: _databaseService.getTransactionHistoryStream(
        userId: currentUserId!, 
        isDonated: isDonated,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error loading history: \${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isDonated ? Icons.volunteer_activism : Icons.inventory_2, 
                  size: 64, 
                  color: Colors.grey.shade400
                ),
                const SizedBox(height: 16),
                Text(
                  isDonated ? 'No items donated yet.' : 'No items received yet.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final items = snapshot.data!;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ItemCard(item: item),
              ),
            );
          },
        );
      },
    );
  }
}
