import 'package:flutter/material.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/models/user_model.dart';
import 'package:green_share/models/item_model.dart';
import 'package:green_share/widgets/item_card.dart';
import 'package:green_share/screens/profile/transaction_history_screen.dart';
import 'package:green_share/screens/profile/edit_profile_screen.dart';

import 'package:green_share/models/review_model.dart';
import 'package:green_share/models/feedback_model.dart';
import 'package:green_share/models/report_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:green_share/main.dart'; // import the context extension
import 'package:provider/provider.dart';
import 'package:green_share/providers/locale_provider.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // Optional: if provided, we view this user's profile instead of our own

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late String? currentUserId;
  bool isOwnProfile = true;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null && widget.userId != FirebaseAuth.instance.currentUser?.uid) {
      currentUserId = widget.userId;
      isOwnProfile = false;
    } else {
      currentUserId = FirebaseAuth.instance.currentUser?.uid;
      isOwnProfile = true;
    }
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.submitFeedback),
          content: TextField(
            controller: feedbackController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: context.l10n.tellUsWhatYouThink,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = feedbackController.text.trim();
                if (text.isNotEmpty && currentUserId != null) {
                  await _databaseService.submitFeedback(
                    FeedbackModel(
                      id: '',
                      userId: currentUserId!,
                      message: text,
                      createdAt: DateTime.now(),
                      status: 'New',
                    ),
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.feedbackSubmitted)),
                    );
                  }
                }
              },
              child: Text(context.l10n.submit),
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog() async {
    final reporterId = FirebaseAuth.instance.currentUser?.uid;
    if (reporterId == null || currentUserId == null) return;

    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.reportUser),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: context.l10n.reasonForReporting,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  // Fetch names for embedding
                  final reporterUser = await _databaseService.getUserProfile(reporterId);
                  final reportedUser = await _databaseService.getUserProfile(currentUserId!);
                  
                  if (reporterUser != null && reportedUser != null) {
                    await _databaseService.submitReport(
                      ReportModel(
                        id: '',
                        reporterId: reporterId,
                        reporterName: reporterUser.name,
                        reportedUserId: currentUserId!,
                        reportedUserName: reportedUser.name,
                        reason: reason,
                        status: 'New',
                        createdAt: DateTime.now(),
                      ),
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.l10n.reportSubmitted)),
                      );
                    }
                  }
                }
              },
              child: Text(context.l10n.submit),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.profile)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.l10n.pleaseLogInToViewProfile),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: Text(context.l10n.logIn),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? context.l10n.profile : context.l10n.donorProfile),
        actions: isOwnProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final user = await _databaseService.getUserProfile(currentUserId!);
                    if (user != null && context.mounted) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(user: user),
                        ),
                      );
                      if (result == true) {
                        setState(() {}); // Refresh future builder
                      }
                    }
                  },
                )
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.flag, color: Colors.orange),
                  onPressed: _showReportDialog,
                )
              ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _databaseService.getUserProfile(currentUserId!),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError || !userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('Error loading profile.'));
          }

          final user = userSnapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 40,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    if (user.role == 'Charity' && user.isApproved) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.green, size: 24),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.communityMember,
                  style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.volunteer_activism, color: AppTheme.primaryColor, size: 24),
                    const SizedBox(width: 8),
                    Text('${user.givenItemsCount} ${context.l10n.given}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 24),
                    Container(width: 1, height: 24, color: Colors.grey),
                    const SizedBox(width: 24),
                    const Icon(Icons.inventory_2, color: Colors.deepOrange, size: 24),
                    const SizedBox(width: 8),
                    Text('${user.receivedItemsCount} ${context.l10n.received}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Average Rating Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RatingBarIndicator(
                      rating: user.averageRating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 24.0,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${user.averageRating.toStringAsFixed(1)} (${user.totalReviews} reviews)',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                
                // Active Listings Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isOwnProfile ? context.l10n.yourListings : context.l10n.activeListings ?? 'Active Listings',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(
                  height: 220,
                  child: StreamBuilder<List<ItemModel>>(
                    stream: _databaseService.getUserItemsStream(currentUserId!),
                    builder: (context, itemSnapshot) {
                      if (itemSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!itemSnapshot.hasData || itemSnapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(context.l10n.noItemsPostedYet, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }

                      final items = itemSnapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 16.0),
                            child: ItemCard(item: items[index]),
                          );
                        },
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                
                // Reviews Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.reviews,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                StreamBuilder<List<ReviewModel>>(
                  stream: _databaseService.getUserReviewsStream(currentUserId!),
                  builder: (context, reviewSnapshot) {
                    if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                    }
                    final reviews = reviewSnapshot.data ?? [];
                    
                    if (reviews.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(context.l10n.noReviewsYet, style: const TextStyle(color: Colors.grey)),
                      );
                    }

                    return SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: 16.0),
                            child: Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            review.reviewerName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          DateFormat.yMMMd().format(review.timestamp),
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    RatingBarIndicator(
                                      rating: review.rating,
                                      itemBuilder: (context, index) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      itemCount: 5,
                                      itemSize: 18.0,
                                      direction: Axis.horizontal,
                                    ),
                                    if (review.comment.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Expanded(
                                        child: Text(
                                          review.comment,
                                          style: const TextStyle(color: Colors.black87, height: 1.4),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                if (isOwnProfile) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(context.l10n.transactionHistory),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(context.l10n.languageSetting),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                       final provider = Provider.of<LocaleProvider>(context, listen: false);
                       if (provider.locale.languageCode == 'en') {
                         provider.setLocale(const Locale('ar'));
                       } else {
                         provider.setLocale(const Locale('en'));
                       }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.feedback_outlined),
                    title: Text(context.l10n.submitFeedback),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showFeedbackDialog,
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(context.l10n.logout, style: const TextStyle(color: Colors.red)),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
