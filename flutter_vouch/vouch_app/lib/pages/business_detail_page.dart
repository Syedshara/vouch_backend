import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vouch_app/providers/review_provider.dart';
import 'package:vouch_app/app_theme.dart';
import 'package:vouch_app/components/add_review_dialog.dart';
import 'package:vouch_app/components/add_tip_dialog.dart';

class BusinessDetailPage extends StatefulWidget {
  final String businessId;
  final String businessName;
  final String category;
  final String location;

  const BusinessDetailPage({
    super.key,
    required this.businessId,
    required this.businessName,
    required this.category,
    required this.location,
  });

  @override
  State<BusinessDetailPage> createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  int _selectedTab = 0; // 0: Reviews, 1: Tips

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        businessId: widget.businessId,
        businessName: widget.businessName,
        onSubmit: (rating, comment) {
          final reviewProvider = context.read<ReviewProvider>();
          final review = Review(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            businessId: widget.businessId,
            userId: 'current_user',
            userName: 'You',
            rating: rating,
            comment: comment,
            createdAt: DateTime.now(),
            isVerified: true,
          );
          reviewProvider.addReview(review);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully!')),
          );
        },
      ),
    );
  }

  void _showAddTipDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTipDialog(
        businessId: widget.businessId,
        businessName: widget.businessName,
        onSubmit: (content) {
          final reviewProvider = context.read<ReviewProvider>();
          final tip = Tip(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 'current_user',
            userName: 'You',
            content: content,
            createdAt: DateTime.now(),
          );
          reviewProvider.addTip(widget.businessId, tip);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tip shared successfully!')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    final reviews = reviewProvider.getBusinessReviews(widget.businessId);
    final tips = reviewProvider.getBusinessTips(widget.businessId);
    final avgRating = reviewProvider.getAverageRating(widget.businessId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.businessName),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Header
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.businessName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.category, size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Text(widget.category, style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Expanded(child: Text(widget.location, style: TextStyle(color: Colors.grey[400]))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Rating Section
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < avgRating.toInt() ? Icons.star : Icons.star_border,
                              color: AppTheme.primary,
                              size: 20,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${avgRating.toStringAsFixed(1)} (${reviews.length} reviews)',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tab Selector
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Column(
                          children: [
                            Text(
                              'Reviews (${reviews.length})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _selectedTab == 0 ? AppTheme.primary : Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_selectedTab == 0)
                              Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Column(
                          children: [
                            Text(
                              'Tips (${tips.length})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _selectedTab == 1 ? AppTheme.primary : Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_selectedTab == 1)
                              Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _selectedTab == 0
                  ? reviews.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No reviews yet. Be the first to review!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
                  : Column(
                children: List.generate(reviews.length, (index) {
                  final review = reviews[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 50 * index),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  review.userName,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Verified',
                                    style: TextStyle(fontSize: 10, color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < review.rating.toInt() ? Icons.star : Icons.star_border,
                                  color: AppTheme.primary,
                                  size: 16,
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Text(review.comment, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              )
                  : tips.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No tips yet. Share your experience!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
                  : Column(
                children: List.generate(tips.length, (index) {
                  final tip = tips[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 50 * index),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tip.userName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                Text(
                                  '${tip.upvotes} upvotes',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(tip.content, style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                reviewProvider.upvoteTip(widget.businessId, tip.id);
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.thumb_up, size: 14, color: AppTheme.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Helpful',
                                    style: TextStyle(fontSize: 11, color: AppTheme.primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'tip_btn',
            onPressed: _showAddTipDialog,
            label: const Text('Add Tip'),
            icon: const Icon(Icons.lightbulb),
            backgroundColor: AppTheme.primary.withOpacity(0.8),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'review_btn',
            onPressed: _showAddReviewDialog,
            label: const Text('Add Review'),
            icon: const Icon(Icons.rate_review),
          ),
        ],
      ),
    );
  }
}
