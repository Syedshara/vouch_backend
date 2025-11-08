// lib/pages/business_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:vouch/models/business_model.dart';
import 'package:vouch/providers/location_provider.dart';
import 'package:vouch/providers/vouch_provider.dart';
import 'package:vouch/app_theme.dart';
import 'package:vouch/components/geofence_detail_map.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vouch/providers/review_provider.dart';
import 'package:vouch/components/add_review_dialog.dart';
import 'package:vouch/components/add_tip_dialog.dart';
import 'package:vouch/components/pop_token_animation.dart';

class BusinessDetailPage extends StatefulWidget {
  final Business business;

  const BusinessDetailPage({
    super.key,
    required this.business,
  });

  @override
  State<BusinessDetailPage> createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  final MapController _mapController = MapController();
  int _selectedTab = 0; // 0: Reviews, 1: Tips
  bool _showTokenAnimation = false;
  String? _previousToken;
  bool _animationShownForCurrentBusiness = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().fetchReviews(widget.business.id);

      final vouchProvider = context.read<VouchProvider>();

      // Store initial token state BEFORE starting vouch process
      _previousToken = vouchProvider.popToken;

      // If token already exists for this business BEFORE starting the process, mark animation as already shown
      if (vouchProvider.popToken != null) {
        _animationShownForCurrentBusiness = true;
        print('Token already exists for this business, skipping animation');
      }

      context.read<VouchProvider>().startVouchProcess(widget.business);

      // Debug: Print initial vouch status
      print('Initial vouch status: ${vouchProvider.status}');
      print('Initial POP token: ${vouchProvider.popToken}');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<VouchProvider>().stopVouchProcess();
      }
    });
    _mapController.dispose();
    super.dispose();
  }

  void _checkForNewToken(VouchProvider vouchProvider) {
    // Only show animation if:
    // 1. There's a token now
    // 2. There was NO token before (previous was null)
    // 3. Animation hasn't been shown for this business yet
    // 4. Animation is not currently showing
    if (vouchProvider.popToken != null &&
        _previousToken == null &&
        !_animationShownForCurrentBusiness &&
        !_showTokenAnimation) {
      print('🎉 NEW POP token generated! Showing animation...');
      print('Previous: $_previousToken -> Current: ${vouchProvider.popToken}');
      setState(() {
        _showTokenAnimation = true;
        _animationShownForCurrentBusiness = true;
        _previousToken = vouchProvider.popToken;
      });
    } else if (vouchProvider.popToken != _previousToken && vouchProvider.popToken != null) {
      // Just update the previous token without showing animation
      _previousToken = vouchProvider.popToken;
    }
  }

  void _hideTokenAnimation() {
    setState(() {
      _showTokenAnimation = false;
    });
  }

  void _showTokenAnimationManually() {
    setState(() {
      _showTokenAnimation = true;
    });
  }

  void _showAddReviewDialog() {
    final reviewProvider = context.read<ReviewProvider>();
    final vouchProvider = context.read<VouchProvider>();
    final popToken = vouchProvider.popToken;

    if (popToken == null || vouchProvider.status != VouchStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must get a Vouch before you can review!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        businessId: widget.business.id,
        businessName: widget.business.name,
        popToken: popToken,
        onSubmit: (rating, comment) async {
          final String? error = await reviewProvider.submitReview(
            businessId: widget.business.id,
            popToken: popToken,
            rating: rating,
            comment: comment,
          );

          if (mounted) {
            if (error == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Review submitted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showAddTipDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTipDialog(
        businessId: widget.business.id,
        businessName: widget.business.name,
        onSubmit: (content) {
          final reviewProvider = context.read<ReviewProvider>();
          final tip = Tip(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 'current_user',
            userName: 'You',
            content: content,
            createdAt: DateTime.now(),
          );
          reviewProvider.addTip(widget.business.id, tip);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tip shared successfully!')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext ctxt) {
    final locationProvider = ctxt.watch<LocationProvider>();
    final vouchProvider = ctxt.watch<VouchProvider>();
    final reviewProvider = ctxt.watch<ReviewProvider>();

    final userLocation = locationProvider.currentLocation;
    final reviews = reviewProvider.getBusinessReviews(widget.business.id);
    final tips = reviewProvider.getBusinessTips(widget.business.id);
    final avgRating = reviewProvider.getAverageRating(widget.business.id);

    // Check for new token generation
    _checkForNewToken(vouchProvider);

    // Debug: Print status on every rebuild
    print('Build - Vouch status: ${vouchProvider.status}, POP: ${vouchProvider.popToken}');

    return Stack(
      children: [
        // Main content
        Scaffold(
          appBar: AppBar(
            title: Text(widget.business.name),
            elevation: 0,
          ),
          body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userLocation != null)
              SizedBox(
                height: 300,
                child: GeofenceDetailMap(
                  business: widget.business,
                  userLocation: userLocation,
                  mapController: _mapController,
                ),
              )
            else
              Container(
                height: 300,
                color: AppTheme.surface,
                child: const Center(child: CircularProgressIndicator()),
              ),
            FadeInUp(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getBorderColor(vouchProvider.status),
                    width: 2,
                  ),
                ),
                child: _buildVouchStatusWidget(vouchProvider),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.business.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.category, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Text(widget.business.category,
                          style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(widget.business.location,
                              style: TextStyle(color: Colors.grey[400]))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Text('${widget.business.vouchCount} Total Vouches',
                          style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          double rating = avgRating;
                          return Icon(
                            index + 1 <= rating ? Icons.star : (index < rating && index + 1 > rating) ? Icons.star_half : Icons.star_border,
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
            const SizedBox(height: 16),

            // --- Tabs ---
            Padding(
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
                              color: _selectedTab == 0
                                  ? AppTheme.primary
                                  : Colors.grey[400],
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
                              color: _selectedTab == 1
                                  ? AppTheme.primary
                                  : Colors.grey[400],
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
            const SizedBox(height: 16),

            // --- Tab Content ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _selectedTab == 0
                  ? _buildReviewsList(reviews, reviewProvider)
                  : _buildTipsList(tips, reviewProvider),
            ),
            const SizedBox(height: 100), // Extra space for FAB
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
          // Only show "Add Review" if vouch is successful
          if (vouchProvider.status == VouchStatus.success)
            FloatingActionButton.extended(
              heroTag: 'review_btn',
              onPressed: _showAddReviewDialog,
              label: const Text('Add Review'),
              icon: const Icon(Icons.rate_review),
            ),
        ],
      ),
        ),

        // 3D Token Animation Overlay
        if (_showTokenAnimation && vouchProvider.popToken != null)
          PopTokenAnimation(
            popToken: vouchProvider.popToken!,
            onComplete: _hideTokenAnimation,
          ),
      ],
    );
  }

  Widget _buildReviewsList(List<Review> reviews, ReviewProvider reviewProvider) {
    if (reviewProvider.isLoading && reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No reviews yet. Be the first to review!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }
    return Column(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Verified',
                          style:
                          TextStyle(fontSize: 10, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < review.rating.toInt()
                            ? Icons.star
                            : Icons.star_border,
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
    );
  }

  Widget _buildTipsList(List<Tip> tips, ReviewProvider reviewProvider) {
    if (tips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No tips yet. Share your experience!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }
    return Column(
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
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        '${tip.upvotes} upvotes',
                        style:
                        TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(tip.content, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      reviewProvider.upvoteTip(widget.business.id, tip.id);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.thumb_up,
                            size: 14, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Helpful',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.primary),
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
    );
  }

  Color _getBorderColor(VouchStatus status) {
    switch (status) {
      case VouchStatus.inside:
      case VouchStatus.counting:
        return Colors.green;
      case VouchStatus.outside:
        return Colors.redAccent;
      case VouchStatus.success:
        return AppTheme.primary;
      case VouchStatus.error:
        return Colors.redAccent;
      case VouchStatus.idle:
      case VouchStatus.vouching:
        return Colors.grey[800]!;
    }
  }

  Widget _buildVouchStatusWidget(VouchProvider vouchProvider) {
    String title;
    String subtitle;
    Widget icon;
    bool showViewTokenButton = false;

    // EXPLICIT HANDLING OF SUCCESS STATUS - Check token first, regardless of status
    if (vouchProvider.popToken != null) {
      title = 'Vouch Collected!';
      subtitle = 'Proof-of-Presence Token is available.\n\nYou can now review this shop.';
      icon = const Icon(Icons.check_circle, color: AppTheme.primary, size: 40);
      showViewTokenButton = true; // Show button when token exists
    } else if (vouchProvider.status == VouchStatus.success) {
      // Success status but no token yet (shouldn't happen, but handle it)
      title = 'Vouch Collected!';
      subtitle = 'Your vouch has been verified!';
      icon = const Icon(Icons.check_circle, color: AppTheme.primary, size: 40);
    } else {
      switch (vouchProvider.status) {
        case VouchStatus.counting:
          title = 'You are inside!';
          subtitle = 'Hold on... vouching in ${vouchProvider.secondsRemaining}s';

          double progress = 0;
          if (vouchProvider.totalDwellTime > 0) {
            progress = 1.0 -
                (vouchProvider.secondsRemaining /
                    vouchProvider.totalDwellTime);
          }

          icon = CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            color: Colors.green,
            backgroundColor: Colors.green.withOpacity(0.2),
            strokeWidth: 6,
          );
          break;
        case VouchStatus.outside:
          title = 'You are outside the area';
          subtitle = 'Move inside the geofence to start the timer';
          icon = const Icon(Icons.warning, color: Colors.redAccent, size: 40);
          break;
        case VouchStatus.vouching:
          title = 'Vouching...';
          subtitle = 'Sending your proof-of-presence...';
          icon = const CircularProgressIndicator(strokeWidth: 6);
          break;
        case VouchStatus.error:
          title = 'Vouch Failed';
          subtitle = 'We couldn\'t verify your vouch. Please try again.';
          icon = const Icon(Icons.error, color: Colors.redAccent, size: 40);
          break;
        case VouchStatus.idle:
          title = 'Finding your location...';
          subtitle = 'Please wait...';
          icon = const CircularProgressIndicator(strokeWidth: 6);
          break;
        case VouchStatus.inside:
          title = 'You are inside!';
          subtitle = 'Starting vouch process...';
          icon = const Icon(Icons.location_on, color: Colors.green, size: 40);
          break;
        case VouchStatus.success:
        // This shouldn't happen (already handled above), but just in case
          title = 'Vouch Collected!';
          subtitle = 'Check above for your POP token';
          icon = const Icon(Icons.check_circle, color: AppTheme.primary, size: 40);
          break;
      }
    }

    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Center(child: icon),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),

        // Add "View 3D Token" button when token exists
        if (showViewTokenButton) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showTokenAnimationManually,
            icon: const Icon(Icons.view_in_ar, size: 20),
            label: const Text(
              'View 3D Token',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ],
      ],
    );
  }
}