import 'package:flutter/material.dart';
import 'package:green_share/models/item_model.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/screens/chat/chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:green_share/models/user_model.dart';
import 'package:green_share/screens/profile/profile_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ItemDetailsScreen extends StatelessWidget {
  final ItemModel item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final hasLocation = item.latitude != null && item.longitude != null;
    final itemLocation = hasLocation ? LatLng(item.latitude!, item.longitude!) : const LatLng(0, 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Header
            if (item.imageUrls.isNotEmpty)
              CachedNetworkImage(
                imageUrl: item.imageUrls.first,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 300,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 300,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.error),
                ),
              )
            else
              Container(
                height: 300,
                color: Colors.grey.shade200,
                child: Center(
                  child: Icon(Icons.image_outlined, size: 80, color: Colors.grey.shade400),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title.isNotEmpty ? item.title : 'Unknown Item',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Donor Profile Tile
                  FutureBuilder<UserModel?>(
                    future: DatabaseService().getUserProfile(item.ownerId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final user = snapshot.data!;
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(userId: item.ownerId),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                                backgroundImage: user.profileImageUrl != null
                                    ? NetworkImage(user.profileImageUrl!)
                                    : null,
                                child: user.profileImageUrl == null
                                    ? Text(
                                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                        style: const TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        RatingBarIndicator(
                                          rating: user.averageRating,
                                          itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                                          itemCount: 5,
                                          itemSize: 14.0,
                                          direction: Axis.horizontal,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${user.averageRating.toStringAsFixed(1)} (${user.totalReviews})',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description.isNotEmpty ? item.description : 'No description provided.',
                    style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Details Grid
                  const Text(
                    'Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildDetailItem(Icons.category, 'Category', item.category),
                      const SizedBox(width: 24),
                      _buildDetailItem(Icons.info_outline, 'Condition', item.condition),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Location Map
                  if (hasLocation) ...[
                    const Text(
                      'Location',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 200,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: itemLocation,
                            initialZoom: 14.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            )
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.greenshare',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: itemLocation,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final lat = item.latitude!;
                          final lng = item.longitude!;
                          final title = Uri.encodeComponent(item.title);
                          final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                          
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open maps application.')),
                            );
                          }
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Open in Google Maps'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Location',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(item.location, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 80), // Padding for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: FirebaseAuth.instance.currentUser?.uid == item.ownerId
                ? (item.status == 'available'
                    ? ElevatedButton.icon(
                        onPressed: () => _markAsCompleted(context),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(item.type == 'Donate' ? 'Mark as Donated' : 'Mark as Completed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              item.type == 'Donate' ? 'Donated' : 'Completed',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ))
                : ElevatedButton.icon(
                    onPressed: () => _contactUser(context),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(item.type == 'Donate' ? 'Contact Donor' : 'Contact Requester'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _contactUser(BuildContext context) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to contact the user.')),
      );
      return;
    }

    if (currentUserId == item.ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This is your own item!')),
      );
      return;
    }

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
              Navigator.pop(context); // Pop back to previous screen

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
}
