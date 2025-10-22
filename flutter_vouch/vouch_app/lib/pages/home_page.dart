import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vouch_app/app_theme.dart';
import 'package:vouch_app/components/top_10_carousel.dart';
import 'package:vouch_app/components/filter_panel.dart';
import 'package:vouch_app/components/map_view.dart';
import 'package:vouch_app/components/business_card.dart';
import 'package:vouch_app/pages/business_detail_page.dart';
import 'package:vouch_app/providers/location_provider.dart';
import 'package:vouch_app/providers/business_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMapView = false;
  String _selectedCategory = 'All';
  String _selectedSort = 'distance';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = context.read<LocationProvider>();
      if (!locationProvider.locationPermissionGranted) {
        locationProvider.requestLocationPermission();
      } else if (locationProvider.currentLocation == null) {
        locationProvider.getCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _simulateVouch(BuildContext context, String placeName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primary,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Vouch collected at $placeName!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
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
          if (locationProvider.isLoading) {
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
                    onPressed: () => locationProvider.requestLocationPermission(),
                    child: const Text('Enable Location'),
                  ),
                ],
              ),
            );
          }

          final userLocation = locationProvider.currentLocation;
          if (userLocation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final nearbyBusinesses = businessProvider.getNearbyBusinesses(
            userLocation.latitude,
            userLocation.longitude,
          );

          final displayBusinesses = businessProvider.searchQuery.isEmpty
              ? nearbyBusinesses
              : businessProvider.filteredBusinesses;

          if (_isMapView) {
            return MapView(
              userLat: userLocation.latitude,
              userLon: userLocation.longitude,
              businesses: displayBusinesses,
              onBusinessTap: (business) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusinessDetailPage(
                      businessId: business.id,
                      businessName: business.name,
                      category: business.category,
                      location: business.location,
                    ),
                  ),
                );
              },
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
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
              const SizedBox(height: 16),
              if (displayBusinesses.isEmpty)
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
                          'Try searching for a different location or category',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Text(
                  'Nearby Shops (${displayBusinesses.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.builder(
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusinessDetailPage(
                              businessId: business.id,
                              businessName: business.name,
                              category: business.category,
                              location: business.location,
                            ),
                          ),
                        );
                      },
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
