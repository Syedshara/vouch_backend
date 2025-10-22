import 'package:flutter/material.dart';

class Tip {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;
  int upvotes;

  Tip({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.upvotes = 0,
  });
}

class Review {
  final String id;
  final String businessId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final List<String>? photoUrls;
  final DateTime createdAt;
  final bool isVerified; // Has Vouch

  Review({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.photoUrls,
    required this.createdAt,
    this.isVerified = true,
  });
}

class ReviewProvider with ChangeNotifier {
  final Map<String, List<Review>> _businessReviews = {
    'annapoorna': [
      Review(
        id: '1',
        businessId: 'annapoorna',
        userId: 'user1',
        userName: 'Raj Kumar',
        rating: 5,
        comment: 'Amazing filter coffee! Best in the city.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isVerified: true,
      ),
      Review(
        id: '2',
        businessId: 'annapoorna',
        userId: 'user2',
        userName: 'Priya Singh',
        rating: 4.5,
        comment: 'Great ambiance and friendly staff.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerified: true,
      ),
    ],
    'brookfields': [
      Review(
        id: '3',
        businessId: 'brookfields',
        userId: 'user3',
        userName: 'Amit Patel',
        rating: 4,
        comment: 'Good shopping experience, parking could be better.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isVerified: true,
      ),
    ],
  };

  final Map<String, List<Tip>> _businessTips = {
    'annapoorna': [
      Tip(
        id: '1',
        userId: 'user1',
        userName: 'Raj Kumar',
        content: 'Try the Ghee Roast, it\'s the best!',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        upvotes: 12,
      ),
      Tip(
        id: '2',
        userId: 'user2',
        userName: 'Priya Singh',
        content: 'Visit during morning for fresh dosas.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        upvotes: 8,
      ),
    ],
    'brookfields': [
      Tip(
        id: '3',
        userId: 'user3',
        userName: 'Amit Patel',
        content: 'Parking is difficult on weekends.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        upvotes: 15,
      ),
    ],
  };

  List<Review> getBusinessReviews(String businessId) {
    return _businessReviews[businessId] ?? [];
  }

  List<Tip> getBusinessTips(String businessId) {
    final tips = _businessTips[businessId] ?? [];
    tips.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    return tips;
  }

  double getAverageRating(String businessId) {
    final reviews = getBusinessReviews(businessId);
    if (reviews.isEmpty) return 0;
    return reviews.fold(0.0, (sum, review) => sum + review.rating) / reviews.length;
  }

  void addReview(Review review) {
    if (!_businessReviews.containsKey(review.businessId)) {
      _businessReviews[review.businessId] = [];
    }
    _businessReviews[review.businessId]!.insert(0, review);
    notifyListeners();
  }

  void addTip(String businessId, Tip tip) {
    if (!_businessTips.containsKey(businessId)) {
      _businessTips[businessId] = [];
    }
    _businessTips[businessId]!.insert(0, tip);
    notifyListeners();
  }

  void upvoteTip(String businessId, String tipId) {
    final tips = _businessTips[businessId];
    if (tips != null) {
      final tipIndex = tips.indexWhere((t) => t.id == tipId);
      if (tipIndex != -1) {
        tips[tipIndex].upvotes++;
        notifyListeners();
      }
    }
  }
}
