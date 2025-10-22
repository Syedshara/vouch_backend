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
  });

  double getDistance(double userLat, double userLon) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((latitude - userLat) * p) / 2 + cos(userLat * p) * cos(latitude * p) * (1 - cos((longitude - userLon) * p)) / 2;
    return (12742 * asin(sqrt(a))).toDouble();
  }
}
