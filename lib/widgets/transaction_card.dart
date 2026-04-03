import 'package:flutter/material.dart';
import 'package:green_share/main.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/models/item_model.dart';
import 'package:green_share/models/review_model.dart';

class TransactionCard extends StatefulWidget {
  final String currentUserId;

  const TransactionCard({super.key, required this.currentUserId});

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ItemModel>>(
      stream: _databaseService.getPendingReceivedItemsStream(widget.currentUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // Hide if no pending items
        }

        final pendingItems = snapshot.data!;
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: pendingItems.map((item) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.green.shade50,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.green.shade200, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.handshake, color: Colors.green),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Action Required: Confirm Receipt',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You have a pending transaction for "${item.title}". Please confirm once you have received it!',
                      style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () => _confirmReceipt(item),
                      child: const Text('Received', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _confirmReceipt(ItemModel item) async {
    try {
      // 1. Update status to completed
      await _databaseService.updateItemStatus(item.id, 'completed');
      
      // 2. Trigger review dialog immediately
      if (mounted) {
        _showReviewDialog(context, item);
      }
    } catch (e) {
      debugPrint('Error confirming receipt: $e');
    }
  }

  void _showReviewDialog(BuildContext context, ItemModel item) {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Force them to review or explicitly cancel
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.rateAndReview),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.howWasExperience),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: context.l10n.commentOptional,
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction completed!')),
                );
              },
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog

                try {
                  final currentUser = await _databaseService.getUserProfile(widget.currentUserId);
                  
                  // Donor ID is item.ownerId if Donate. If Request, Donor is item.receiverId
                  final realDonorId = item.type == 'Donate' ? item.ownerId : item.receiverId!;

                  final review = ReviewModel(
                    id: '', // Will be generated by addReview
                    reviewerId: widget.currentUserId,
                    reviewerName: currentUser?.name ?? 'Anonymous',
                    donorId: realDonorId,
                    recipientId: widget.currentUserId,
                    itemId: item.id,
                    rating: rating,
                    comment: commentController.text.trim(),
                    timestamp: DateTime.now(),
                  );
                  
                  await _databaseService.addReview(review);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.reviewSubmitted)),
                    );
                  }
                } catch (e) {
                  debugPrint('Error submitting review: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.reviewFailed)),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.white),
              child: Text(context.l10n.submit),
            ),
          ],
        ),
      ),
    );
  }
}
