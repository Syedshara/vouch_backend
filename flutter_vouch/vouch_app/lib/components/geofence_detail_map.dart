import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vouch/models/business_model.dart';
import 'package:vouch/app_theme.dart';
import 'dart:convert';
import 'package:vouch/providers/location_provider.dart';

class GeofenceDetailMap extends StatelessWidget {
  final Business business;
  final LocationData userLocation;
  final MapController mapController;

  const GeofenceDetailMap({
    super.key,
    required this.business,
    required this.userLocation,
    required this.mapController,
  });

  Polygon _buildGeofencePolygon() {
    if (business.geofenceGeoJson == null) {
      return Polygon(points: [], color: Colors.transparent);
    }
    try {
      final geoJson = jsonDecode(business.geofenceGeoJson!);
      final List<dynamic> coordinates = geoJson['coordinates'][0];
      final List<LatLng> points =
      coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

      return Polygon(
        points: points,
        color: AppTheme.primary.withOpacity(0.15),
        borderColor: AppTheme.primary,
        borderStrokeWidth: 2,
        isFilled: true,
      );
    } catch (e) {
      print('Error parsing geofence: $e');
      return Polygon(points: [], color: Colors.transparent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        // Center on the business, not the user
        initialCenter: LatLng(business.latitude, business.longitude),
        initialZoom: 17.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.vouch_app',
        ),
        PolygonLayer(polygons: [_buildGeofencePolygon()]),
        MarkerLayer(
          markers: [
            // User location marker
            Marker(
              point: LatLng(userLocation.latitude, userLocation.longitude),
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}