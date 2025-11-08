import 'dart:convert';
import 'package:latlong2/latlong.dart';

class GeofenceService {
  // Parses the GeoJSON string and returns a list of LatLng points
  List<LatLng> _getPolygonPoints(String geofenceGeoJson) {
    try {
      final geoJson = jsonDecode(geofenceGeoJson);
      final List<dynamic> coordinates = geoJson['coordinates'][0];
      final List<LatLng> points = coordinates
          .map((coord) => LatLng(coord[1], coord[0])) // GeoJSON is (lon, lat)
          .toList();
      return points;
    } catch (e) {
      print('Error parsing geofence: $e');
      return [];
    }
  }

  // Ray-casting algorithm to check if a point is inside a polygon
  bool isPointInGeofence(LatLng point, String geofenceGeoJson) {
    final polygon = _getPolygonPoints(geofenceGeoJson);
    if (polygon.isEmpty) return false;

    int crossings = 0;
    for (int i = 0; i < polygon.length; i++) {
      final LatLng p1 = polygon[i];
      final LatLng p2 = polygon[(i + 1) % polygon.length];

      if (((p1.longitude <= point.longitude && point.longitude < p2.longitude) ||
          (p2.longitude <= point.longitude && point.longitude < p1.longitude)) &&
          (point.latitude < (p2.latitude - p1.latitude) * (point.longitude - p1.longitude) / (p2.longitude - p1.longitude) + p1.latitude)) {
        crossings++;
      }
    }
    return crossings % 2 == 1;
  }
}