import 'package:flutter/material.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/models/item_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/screens/chat/chat_screen.dart';
import 'package:green_share/screens/home/item_details_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:green_share/models/review_model.dart';
import 'package:green_share/models/user_model.dart';
import 'package:green_share/screens/profile/profile_screen.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrls.isNotEmpty;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(item: item),
          ),
        );
      },
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias, // Ensures internal content doesn't bleed out of rounded corners
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                image: hasImage
                    ? DecorationImage(
                        image: NetworkImage(item.imageUrls.first),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: !hasImage
                  ? Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400)
                  : null,
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title.isNotEmpty ? item.title : 'Unknown Item',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.type == 'Donate' 
                              ? AppTheme.primaryColor.withOpacity(0.1) 
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.type,
                          style: TextStyle(
                            color: item.type == 'Donate' 
                                ? AppTheme.primaryColor 
                                : Colors.deepOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<UserModel?>(
                    future: DatabaseService().getUserProfile(item.ownerId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final user = snapshot.data!;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(userId: item.ownerId),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                              backgroundImage: user.profileImageUrl != null
                                  ? NetworkImage(user.profileImageUrl!)
                                  : null,
                              child: user.profileImageUrl == null
                                  ? Text(
                                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                user.name,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              user.averageRating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Text(
                      item.description.isNotEmpty ? item.description : 'No description provided.',
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                        _buildChip(Icons.category_outlined, item.category),
                      _buildChip(Icons.location_on_outlined, item.city ?? item.location),
                      if (item.type == 'Donate' && item.condition.isNotEmpty)
                        _buildChip(Icons.info_outline, item.condition),
                    ],
                  ),
                  const Spacer(),
                  if (FirebaseAuth.instance.currentUser?.uid == item.ownerId)
                    if (item.status == 'available')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _markAsCompleted(context),
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: Text(item.type == 'Donate' ? 'Mark as Donated' : 'Mark as Completed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.withOpacity(0.1),
                            foregroundColor: Colors.green,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.grey, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              item.type == 'Donate' ? 'Donated' : 'Completed',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                          if (currentUserId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please log in to contact the user.')),
                            );
                            return;
                          }

                          // Create or Get Chat Room
                          final dbContext = context;
                          showDialog(
                            context: dbContext,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator()),
                          );
                          
                          try {
                            final db = DatabaseService();
                            final chatId = await db.createOrGetChatRoom(currentUserId, item.ownerId, itemId: item.id);
                            final otherUser = await db.getUserProfile(item.ownerId);
                            
                            if (dbContext.mounted) {
                              Navigator.pop(dbContext); // close dialog
                              Navigator.push(
                                dbContext,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    chatId: chatId,
                                    otherUserId: item.ownerId,
                                    otherUserName: otherUser?.name ?? 'Community Member',
                                    itemId: item.id,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                             if (dbContext.mounted) {
                              Navigator.pop(dbContext);
                              ScaffoldMessenger.of(dbContext).showSnackBar(
                                const SnackBar(content: Text('Error starting chat.')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: Text(item.type == 'Donate' ? 'Contact Donor' : 'Contact Requester'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          foregroundColor: AppTheme.primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  
                  // Rating Button for Receiver
                  if (item.receiverId != null && 
                      FirebaseAuth.instance.currentUser?.uid == item.receiverId &&
                      item.status == 'donated')
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: item.hasBeenRated
                            ? Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.star, color: Colors.green, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Rated',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () => _showRatingDialog(context),
                                icon: const Icon(Icons.star_outline, size: 18),
                                label: const Text('Rate Donor'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber.shade50,
                                  foregroundColor: Colors.amber.shade900,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondaryColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _markAsCompleted(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.type == 'Donate' ? 'Mark as Donated?' : 'Mark as Completed?'),
        content: Text(
          item.type == 'Donate'
              ? 'Are you sure you want to mark this item as donated? This will remove it from the home page.'
              : 'Are you sure you want to mark this request as completed? This will remove it from the home page.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close confirmation dialog
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Status updated successfully!')),
              );

              // Run DB operations asynchronously without blocking the UI
              () async {
                try {
                  final db = DatabaseService();
                  await db.updateItemStatus(item.id, 'donated');
                  await db.incrementAwardStats(ownerId: item.ownerId, itemType: item.type);
                } catch (e) {
                  print('Error updating status: $e');
                }
              }();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Yes, confirm'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
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
                  
                  final review = ReviewModel(
                    id: '',
                    reviewerId: currentUserId,
                    reviewerName: currentUser?.name ?? 'User',
                    donorId: item.ownerId,
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
