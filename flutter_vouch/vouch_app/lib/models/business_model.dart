import 'dart:math';

class Business {
  final String id;
  final String name;
  final String category;
  final String location;
  final double latitude;
  final double longitude;
  final String campaign;
  final double rating;
  final int vouchCount;
  final String? imageUrl;
  final String? description;
  final String? geofenceGeoJson;
  final int dwellTimeMinutes; // <-- FIX: Added this field (was missing)

  Business({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.campaign,
    required this.rating,
    required this.vouchCount,
    this.imageUrl,
    this.description,
    this.geofenceGeoJson,
    required this.dwellTimeMinutes, // <-- FIX: Added to constructor
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Name',
      category: json['category'] ?? 'General',
      location: json['address'] ?? 'No address',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      campaign: json['campaign'] ?? 'No active campaign',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      vouchCount: (json['vouchCount'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'],
      description: json['description'],
      geofenceGeoJson: json['geofence'],
      // <-- FIX: Added this line to get the value from JSON
      // Use a default value (e.g., 5 minutes) if it's null
      dwellTimeMinutes: (json['dwell_time_minutes'] as num?)?.toInt() ?? 5,
    );
  }

  double getDistance(double userLat, double userLon) {
    // ... (this function is fine)
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((latitude - userLat) * p) / 2 +
        cos(userLat * p) *
            cos(latitude * p) *
            (1 - cos((longitude - userLon) * p)) / 2;
    return (12742 * asin(sqrt(a))).toDouble();
  }
}