import 'package:flutter/material.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/models/item_model.dart';
import 'package:green_share/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_share/screens/home/item_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:green_share/models/review_model.dart';
import 'package:green_share/core/localization_helpers.dart';
import 'package:green_share/main.dart';

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
            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailsScreen(item: item),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          image: item.imageUrls.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(item.imageUrls.first),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: item.imageUrls.isEmpty
                            ? Icon(Icons.image_outlined, color: Colors.grey.shade400)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocalizationHelpers.getCategory(context, item.category),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat.yMMMd().format(item.postedAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Status / Badge and Rating Button
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDonated ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isDonated ? context.l10n.given : context.l10n.received,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDonated ? Colors.green : Colors.blue,
                              ),
                            ),
                          ),
                          if ((item.status == 'donated' || item.status == 'completed') && 
                              ((item.type == 'Donate' && item.receiverId != null && FirebaseAuth.instance.currentUser?.uid == item.receiverId) ||
                               (item.type == 'Request' && item.ownerId == FirebaseAuth.instance.currentUser?.uid)))
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: item.hasBeenRated
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.star, color: Colors.green, size: 12),
                                          SizedBox(width: 4),
                                          Text(
                                            'Rated',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () => _showRatingDialog(context, item),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.star_outline, color: Colors.amber.shade900, size: 12),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Rate',
                                              style: TextStyle(
                                                color: Colors.amber.shade900,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context, ItemModel item) {
    double _rating = 5.0;
    final _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Rate Donor', style: TextStyle(color: AppTheme.primaryColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('How was your experience?', style: TextStyle(color: Colors.black87)),
                const SizedBox(height: 16),
                RatingBar.builder(
                  initialRating: 5,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    _rating = rating;
                  },
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Leave a brief review (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                if (currentUserId == null) return;
                
                // Show loading
                Navigator.pop(dialogContext);
                showDialog(
                  context: context, 
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator())
                );

                try {
                  final db = DatabaseService();
                  final currentUser = await db.getUserProfile(currentUserId);
                  final realDonorId = item.type == 'Donate' ? item.ownerId : item.receiverId ?? item.ownerId;

                  final review = ReviewModel(
                    id: '',
                    reviewerId: currentUserId,
                    reviewerName: currentUser?.name ?? 'User',
                    donorId: realDonorId,
                    recipientId: currentUserId,
                    itemId: item.id,
                    rating: _rating,
                    comment: _commentController.text.trim(),
                    timestamp: DateTime.now(),
                  );

                  await db.addReview(review);
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Hide loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thank you for your rating!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // Hide loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to submit review.')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
