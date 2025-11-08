import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vouch/models/business_model.dart';
import 'package:vouch/app_theme.dart';
import 'dart:convert';

class MapView extends StatefulWidget {
  final double userLat;
  final double userLon;
  final List<Business> businesses;
  final Function(Business) onBusinessTap;

  const MapView({
    super.key,
    required this.userLat,
    required this.userLon,
    required this.businesses,
    required this.onBusinessTap,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<Polygon> _buildGeofencePolygons() {
    final List<Polygon> polygons = [];
    for (final business in widget.businesses) {
      if (business.geofenceGeoJson != null) {
        try {
          final geoJson = jsonDecode(business.geofenceGeoJson!);
          final List<dynamic> coordinates = geoJson['coordinates'][0];
          final List<LatLng> points = coordinates
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList();

          polygons.add(
            Polygon(
              points: points,
              color: AppTheme.primary.withOpacity(0.15),
              borderColor: AppTheme.primary,
              borderStrokeWidth: 2,
              isFilled: true,
            ),
          );
        } catch (e) {
          print('Error parsing geofence: $e');
        }
      }
    }
    return polygons;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(widget.userLat, widget.userLon),
        initialZoom: 14.0,
        minZoom: 5.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          // --- THIS IS THE FIX ---
          // You must use a unique user agent.
          userAgentPackageName: 'com.example.vouch_app',
        ),
        PolygonLayer(polygons: _buildGeofencePolygons()),
        MarkerLayer(
          markers: [
            // User location marker
            Marker(
              point: LatLng(widget.userLat, widget.userLon),
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
            // Business markers (at their center point)
            ...widget.businesses.map((business) {
              return Marker(
                point: LatLng(business.latitude, business.longitude),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => widget.onBusinessTap(business),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.store,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }
}