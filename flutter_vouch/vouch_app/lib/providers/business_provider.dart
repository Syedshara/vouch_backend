import 'package:flutter/material.dart';
import 'package:vouch_app/models/business_model.dart';

class BusinessProvider with ChangeNotifier {
  final List<Business> _allBusinesses = [
    Business(
      id: 'annapoorna',
      name: 'Annapoorna Gowrishankar',
      category: 'South Indian',
      location: 'RS Puram, Coimbatore',
      latitude: 11.0211,
      longitude: 76.9544,
      campaign: 'Visit 3 times, get a free filter coffee!',
      rating: 4.8,
      vouchCount: 1250,
      imageUrl: 'https://images.unsplash.com/photo-1585521537688-e42dc4efcadd?w=400&h=300&fit=crop',
      description: 'Authentic South Indian restaurant with traditional recipes',
    ),
    Business(
      id: 'brookfields',
      name: 'Brookfields Mall',
      category: 'Shopping',
      location: 'Gandhipuram, Coimbatore',
      latitude: 11.0081,
      longitude: 76.9539,
      campaign: 'Spend ₹2000, get 100 points!',
      rating: 4.7,
      vouchCount: 2100,
      imageUrl: 'https://images.unsplash.com/photo-1567521464027-f127ff144326?w=400&h=300&fit=crop',
      description: 'Premium shopping destination with 200+ brands',
    ),
    Business(
      id: 'frenchdoor',
      name: 'The French Door',
      category: 'Cafe & Bakery',
      location: 'Peelamedu, Coimbatore',
      latitude: 11.0161,
      longitude: 76.9689,
      campaign: 'Every 5th visit gets a free pastry!',
      rating: 4.6,
      vouchCount: 890,
      imageUrl: 'https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=400&h=300&fit=crop',
      description: 'Cozy cafe with freshly baked pastries and artisan coffee',
    ),
    Business(
      id: 'crosscut',
      name: 'Cross-Cut Road',
      category: 'Street Shopping',
      location: 'Cross-Cut Road, Coimbatore',
      latitude: 11.0251,
      longitude: 76.9456,
      campaign: 'Vouch at 3 shops, get a surprise reward!',
      rating: 4.5,
      vouchCount: 1560,
      imageUrl: 'https://images.unsplash.com/photo-1555529669-e69e7f0acec8?w=400&h=300&fit=crop',
      description: 'Popular shopping street with diverse retail stores',
    ),
    Business(
      id: 'brewheaven',
      name: 'Brew Haven',
      category: 'Coffee Shop',
      location: 'Saibaba Colony, Coimbatore',
      latitude: 11.0341,
      longitude: 76.9589,
      campaign: 'Buy 4 coffees, get 1 free!',
      rating: 4.5,
      vouchCount: 750,
      imageUrl: 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=400&h=300&fit=crop',
      description: 'Specialty coffee roastery with premium blends',
    ),
    Business(
      id: 'phoenixmarket',
      name: 'Phoenix Market',
      category: 'Shopping',
      location: 'Gandhipuram, Coimbatore',
      latitude: 11.0091,
      longitude: 76.9549,
      campaign: 'Weekend special: Extra 20% off!',
      rating: 4.3,
      vouchCount: 1200,
      imageUrl: 'https://images.unsplash.com/photo-1567521464027-f127ff144326?w=400&h=300&fit=crop',
      description: 'Multi-brand shopping complex with food court',
    ),
  ];

  List<Business> _filteredBusinesses = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<Business> get allBusinesses => _allBusinesses;
  List<Business> get filteredBusinesses => _filteredBusinesses.isEmpty ? _allBusinesses : _filteredBusinesses;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<Business> getNearbyBusinesses(double userLat, double userLon, {double radiusKm = 10.0}) {
    final nearby = _allBusinesses
        .where((business) {
      final distance = business.getDistance(userLat, userLon);
      return distance <= radiusKm;
    })
        .toList();

    nearby.sort((a, b) => a.getDistance(userLat, userLon).compareTo(b.getDistance(userLat, userLon)));
    return nearby;
  }

  void searchBusinesses(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredBusinesses = [];
    } else {
      _filteredBusinesses = _allBusinesses
          .where((business) =>
      business.name.toLowerCase().contains(query.toLowerCase()) ||
          business.category.toLowerCase().contains(query.toLowerCase()) ||
          business.location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<String> getCategories() {
    final categories = _allBusinesses.map((b) => b.category).toSet().toList();
    return ['All', ...categories];
  }
}
