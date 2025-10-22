import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vouch_app/models/business_model.dart';
import 'package:vouch_app/app_theme.dart';

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
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            // User location marker
            Marker(
              point: LatLng(widget.userLat, widget.userLon),
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
            // Business markers
            ...widget.businesses.map((business) {
              return Marker(
                point: LatLng(business.latitude, business.longitude),
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () => widget.onBusinessTap(business),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        business.name.substring(0, 1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                          fontSize: 18,
                        ),
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
