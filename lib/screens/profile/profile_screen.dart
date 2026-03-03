import 'package:flutter/material.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/models/user_model.dart';
import 'package:green_share/models/item_model.dart';
import 'package:green_share/widgets/item_card.dart';
import 'package:green_share/screens/profile/transaction_history_screen.dart';

import 'package:green_share/models/review_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please log in to view your profile.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Log In'),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? 'Profile' : 'Donor Profile'),
        actions: isOwnProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // Open Settings
                  },
                )
              ]
            : null,
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
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Community Member',
                  style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.volunteer_activism, color: AppTheme.primaryColor, size: 24),
                    const SizedBox(width: 8),
                    Text('${user.givenItemsCount} Given', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 24),
                    Container(width: 1, height: 24, color: Colors.grey),
                    const SizedBox(width: 24),
                    const Icon(Icons.inventory_2, color: Colors.deepOrange, size: 24),
                    const SizedBox(width: 8),
                    Text('${user.receivedItemsCount} Received', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                
                // Active Listings Section OR Reviews Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isOwnProfile ? 'Your Listings' : 'Reviews',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (isOwnProfile)
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                    ],
                  ),
                ),
                
                if (isOwnProfile)
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
                                const Text('No items posted yet', style: TextStyle(color: Colors.grey)),
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
                  )
                else
                  // Reviews List for other profiles
                  StreamBuilder<List<ReviewModel>>(
                    stream: _databaseService.getUserReviewsStream(currentUserId!),
                    builder: (context, reviewSnapshot) {
                      if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                      }
                      final reviews = reviewSnapshot.data ?? [];
                      
                      if (reviews.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('No reviews yet.', style: TextStyle(color: Colors.grey)),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12.0),
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
                                      Text(
                                        review.reviewerName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                                    Text(
                                      review.comment,
                                      style: const TextStyle(color: Colors.black87, height: 1.4),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                if (isOwnProfile) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Transaction History'),
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
                    title: const Text('Language (EN/AR)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
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
