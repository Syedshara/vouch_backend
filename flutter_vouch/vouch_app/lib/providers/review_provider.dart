import 'package:flutter/material.dart';
import 'package:vouch/api_config.dart';
import 'package:vouch/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- Tip Model (Unchanged) ---
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

// --- Review Model (Updated) ---
class Review {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final bool isVerified; // This will always be true from our backend

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isVerified = true,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // This factory now matches the backend response
    String userName = 'A Customer';
    if (json['customers'] != null) {
      userName = json['customers']['name'] ?? userName;
    }

    return Review(
      id: json['id'],
      userName: userName,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ReviewProvider with ChangeNotifier {
  final AuthService _authService;
  ReviewProvider(this._authService);

  // --- Switched to real data ---
  final Map<String, List<Review>> _businessReviews = {};
  bool _isLoading = false;

  // --- Tip logic is still mock data (unchanged) ---
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
    ],
  };

  // --- Public Getters ---
  bool get isLoading => _isLoading;
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
    if (reviews.isEmpty) return 0; // Use 0 for no reviews
    return reviews.fold(0.0, (sum, review) => sum + review.rating) / reviews.length;
  }

  // --- NEW: Fetch Real Reviews ---
  Future<void> fetchReviews(String businessId) async {
    // If we already have them, don't re-fetch
    if (_businessReviews.containsKey(businessId)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/public/reviews/$businessId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _businessReviews[businessId] = data.map((json) => Review.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching reviews: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- NEW: Submit a Verified Review ---
  Future<String?> submitReview({
    required String businessId,
    required String popToken,
    required double rating,
    required String comment,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) return "You must be logged in.";

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'location_id': businessId,
          'pop_token': popToken,
          'rating': rating,
          'comment': comment,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Success!
        _businessReviews.remove(businessId); // Clear cache
        await fetchReviews(businessId); // Refetch
        return null; // Return null for success
      } else {
        // Return the error message from the server
        return data['error'] ?? 'Failed to submit review.';
      }
    } catch (e) {
      print("Error submitting review: $e");
      return "An error occurred. Please try again.";
    }
  }

  // --- Tip logic is unchanged ---
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