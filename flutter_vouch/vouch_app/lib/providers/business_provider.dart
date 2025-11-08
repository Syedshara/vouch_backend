import 'package:flutter/material.dart';
import 'package:vouch/models/business_model.dart';
import 'package:vouch/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusinessProvider with ChangeNotifier {
  List<Business> _allBusinesses = [];
  List<Business> _filteredBusinesses = [];
  bool _isLoading = false;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // This is the main list for the grid
  List<Business> get nearbyBusinesses => _allBusinesses;

  // This is the list for search results
  List<Business> get filteredBusinesses => _filteredBusinesses;

  // Derived list for the "Top Rated" carousel
  List<Business> get topBusinesses {
    List<Business> sorted = List.from(_allBusinesses);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(10).toList();
  }

  // Derived list for the "New" carousel
  List<Business> get newBusinesses {
    // Assuming the API sends them in a reasonable order.
    // For a real app, you'd sort by a 'created_at' field.
    return _allBusinesses.take(10).toList();
  }

  // Fetches all businesses from your Node.js backend
  Future<void> fetchAllBusinesses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/public/locations'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _allBusinesses = data.map((json) => Business.fromJson(json)).toList();
      } else {
        // Handle server error
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network error
      print('Network error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Filters the list of businesses based on a search query
  void searchBusinesses(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredBusinesses = [];
    } else {
      _filteredBusinesses = _allBusinesses
          .where((business) =>
      business.name.toLowerCase().contains(query.toLowerCase()) ||
          business.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}