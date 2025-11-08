// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vouch/app_theme.dart';
import 'package:vouch/components/top_10_carousel.dart';
import 'package:vouch/components/filter_panel.dart';
import 'package:vouch/components/map_view.dart';
import 'package:vouch/components/business_card.dart';
// --- THIS IS THE FIX (Part 1) ---
import 'package:vouch/pages/business_detail_page.dart' as BDP;
// ---
import 'package:vouch/providers/location_provider.dart';
import 'package:vouch/providers/business_provider.dart';
import 'package:vouch/models/business_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isMapView = false;
  String _selectedCategory = 'All';
  String _selectedSort = 'distance';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final locationProvider = context.read<LocationProvider>();
    final businessProvider = context.read<BusinessProvider>();

    bool permissionGranted = locationProvider.locationPermissionGranted;

    if (!permissionGranted) {
      permissionGranted = await locationProvider.requestLocationPermission();
    }

    if (permissionGranted) {
      if (locationProvider.currentLocation == null) {
        await locationProvider.getCurrentLocation();
      }
      if (mounted) {
        await businessProvider.fetchAllBusinesses();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterPanel(
        onApply: (category, sortBy) {
          setState(() {
            _selectedCategory = category;
            _selectedSort = sortBy;
          });
        },
      ),
    );
  }

  void _onBusinessTap(Business business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // --- THIS IS THE FIX (Part 2) ---
        builder: (context) => BDP.BusinessDetailPage(
          business: business,
        ),
        // ---
      ),
    );
  }

  void _onTopBusinessTap(int index) {
    final topBusinesses = context.read<BusinessProvider>().topBusinesses;
    if (topBusinesses.length > index) {
      _onBusinessTap(topBusinesses[index]);
    }
  }

  void _onNewBusinessTap(int index) {
    final newBusinesses = context.read<BusinessProvider>().newBusinesses;
    if (newBusinesses.length > index) {
      _onBusinessTap(newBusinesses[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Nearby'),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () => setState(() => _isMapView = !_isMapView),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterPanel,
          ),
        ],
      ),
      body: Consumer2<LocationProvider, BusinessProvider>(
        builder: (context, locationProvider, businessProvider, child) {
          // This should all work now
          if (locationProvider.isLoading || (businessProvider.isLoading && businessProvider.nearbyBusinesses.isEmpty)) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!locationProvider.locationPermissionGranted) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Location permission required'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchData,
                    child: const Text('Enable Location'),
                  ),
                ],
              ),
            );
          }

          final userLocation = locationProvider.currentLocation;
          if (userLocation == null) {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Could not get location. Please try again.'),
                    ElevatedButton(
                      onPressed: _fetchData,
                      child: const Text('Retry'),
                    ),
                  ],
                )
            );
          }

          final nearbyBusinesses = businessProvider.nearbyBusinesses;
          final topBusinesses = businessProvider.topBusinesses;
          final newBusinesses = businessProvider.newBusinesses;

          final displayBusinesses = businessProvider.searchQuery.isEmpty
              ? nearbyBusinesses
              : businessProvider.filteredBusinesses;

          if (_isMapView) {
            return MapView(
              userLat: userLocation.latitude,
              userLon: userLocation.longitude,
              businesses: displayBusinesses,
              onBusinessTap: _onBusinessTap,
            );
          }

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    businessProvider.searchBusinesses(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search shops, cafes, malls...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        businessProvider.searchBusinesses('');
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              if (businessProvider.searchQuery.isEmpty) ...[
                Top10Carousel(
                  title: 'Top Rated Shops',
                  items: topBusinesses.map((b) => {
                    'name': b.name,
                    'rating': b.rating.toStringAsFixed(1),
                    'image': b.imageUrl ?? '',
                  }).toList(),
                  onItemTap: (index) {
                    if(topBusinesses.length > index) _onBusinessTap(topBusinesses[index]);
                  },
                ),
                const SizedBox(height: 32),
                Top10Carousel(
                  title: 'New & Noteworthy',
                  items: newBusinesses.map((b) => {
                    'name': b.name,
                    'rating': b.rating.toStringAsFixed(1),
                    'image': b.imageUrl ?? '',
                  }).toList(),
                  onItemTap: (index) {
                    if(newBusinesses.length > index) _onBusinessTap(newBusinesses[index]);
                  },
                ),
                const SizedBox(height: 32),
              ],

              if (displayBusinesses.isEmpty && businessProvider.searchQuery.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No shops found for your search'),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different keyword',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                )
              else if (displayBusinesses.isEmpty && businessProvider.searchQuery.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.store, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No shops found nearby'),
                        const SizedBox(height: 8),
                        Text(
                          'We are expanding to your area soon!',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      businessProvider.searchQuery.isEmpty ? 'All Nearby Shops' : 'Search Results',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: displayBusinesses.length,
                    itemBuilder: (context, index) {
                      final business = displayBusinesses[index];
                      final distance = business.getDistance(
                        userLocation.latitude,
                        userLocation.longitude,
                      );
                      return BusinessCard(
                        business: business,
                        distance: distance,
                        onTap: () => _onBusinessTap(business),
                      );
                    },
                  ),
                ],
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}