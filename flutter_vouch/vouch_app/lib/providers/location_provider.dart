import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'dart:async'; // We keep this for the Future

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

class LocationProvider with ChangeNotifier {
  LocationData? _currentLocation;
  bool _isLoading = false;
  String? _error;
  bool _locationPermissionGranted = false;

  // --- REMOVED LIVE STREAM SUBSCRIPTION ---

  LocationData? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get locationPermissionGranted => _locationPermissionGranted;

  Future<bool> requestLocationPermission() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        _error = 'Location permission denied';
        _locationPermissionGranted = false;
      } else if (permission == LocationPermission.deniedForever) {
        _error = 'Location permission permanently denied. Please enable it in settings.';
        _locationPermissionGranted = false;
      } else {
        _locationPermissionGranted = true;
        // --- REVERTED: Call one-time fetch ---
        await getCurrentLocation();
      }
    } catch (e) {
      _error = 'Error requesting location permission: $e';
      _locationPermissionGranted = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return _locationPermissionGranted;
  }

  // This is now a one-time fetch
  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _error = 'Location permission not granted';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentLocation = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // --- REMOVED LIVE STREAM CALL ---

    } catch (e) {
      _error = 'Error getting location: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- REMOVED _startLocationStream() and dispose() ---

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return (12742 * asin(sqrt(a))).toDouble();
  }
}