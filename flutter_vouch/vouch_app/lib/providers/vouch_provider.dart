// lib/providers/vouch_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:vouch/api_config.dart';
import 'package:vouch/models/business_model.dart';
import 'package:vouch/providers/location_provider.dart';
import 'package:vouch/providers/reward_provider.dart';
import 'package:vouch/services/auth_service.dart';
import 'package:vouch/services/geofence_service.dart';

enum VouchStatus {
  idle,
  outside,
  counting,
  vouching,
  success,
  error,
  inside
}

class VouchProvider with ChangeNotifier {
  final LocationProvider _locationProvider;
  final AuthService _authService;
  final RewardProvider _rewardProvider;
  final GeofenceService _geofenceService = GeofenceService();

  Business? _currentBusiness;
  VouchStatus _status = VouchStatus.idle;
  Timer? _pollTimer;
  int _secondsRemaining = 0;
  int _totalDwellTime = 0;
  String? _popToken;
  bool _isWaitingForLocation = false;

  Business? get currentBusiness => _currentBusiness;
  VouchStatus get status => _status;
  int get secondsRemaining => _secondsRemaining;
  int get totalDwellTime => _totalDwellTime;
  String? get popToken => _popToken;

  VouchProvider(this._locationProvider, this._authService, this._rewardProvider);

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void startVouchProcess(Business business) {
    print('[VouchProvider] 🚀 Starting vouch process for business: ${business.name} (ID: ${business.id})');

    _pollTimer?.cancel();

    // Check if this is the same business BEFORE updating _currentBusiness
    final isSameBusiness = _currentBusiness?.id == business.id;

    // If same business and already successful, just show success
    if (isSameBusiness && _status == VouchStatus.success && _popToken != null) {
      print('[VouchProvider] ✅ Already have POP token for this business: $_popToken');
      notifyListeners(); // Ensure UI updates
      return;
    }

    // Reset state only if different business
    if (!isSameBusiness) {
      print('[VouchProvider] 🆕 New business, resetting state');
      _popToken = null;
      _status = VouchStatus.idle;
    }

    _currentBusiness = business;
    _totalDwellTime = (business.dwellTimeMinutes * 60);
    _secondsRemaining = _totalDwellTime;
    _isWaitingForLocation = false;

    // Check server status immediately
    _checkServerStatusInitial();
  }

  void stopVouchProcess() {
    print('[VouchProvider] 🛑 Stopping vouch process');
    _pollTimer?.cancel();
    _pollTimer = null;
    _isWaitingForLocation = false;
  }

  Future<void> _checkServerStatusInitial() async {
    if (_currentBusiness == null) return;

    // If we already have a POP token, don't check server again
    if (_popToken != null && _status == VouchStatus.success) {
      print('[VouchProvider] ✅ Already have POP token, skipping initial check');
      notifyListeners();
      return;
    }

    final token = await _authService.getAuthToken();
    if (token == null) {
      print('[VouchProvider] ❌ No auth token available');
      _setStatus(VouchStatus.error);
      return;
    }

    print('[VouchProvider] 🔍 Checking initial server status...');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/vouch/status/${_currentBusiness!.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('[VouchProvider] 📡 Server response status: ${response.statusCode}');
      print('[VouchProvider] 📡 Server response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('[VouchProvider] 📊 Server status: ${data['status']}');

        switch (data['status']) {
          case 'completed':
            _popToken = data['pop_token'];
            print('[VouchProvider] ✅ Found completed vouch! POP Token: $_popToken');
            _setStatus(VouchStatus.success);
            _rewardProvider.fetchRewards();
            // Don't start polling if already completed
            return;

          case 'counting':
            _secondsRemaining = (data['seconds_remaining'] as num).toInt();
            _totalDwellTime = (data['dwell_time_total'] as num).toInt();
            print('[VouchProvider] ⏱️ Timer counting: ${_secondsRemaining}s remaining');

            if (_secondsRemaining <= 0) {
              await _stopServerTimer();
            } else {
              _setStatus(VouchStatus.counting);
              _startPolling();
            }
            break;

          case 'idle':
            print('[VouchProvider] 💤 Server says idle, checking geofence...');
            _setStatus(VouchStatus.idle);
            _checkGeofenceStatus();
            _startPolling();
            break;

          default:
            print('[VouchProvider] ⚠️ Unknown status: ${data['status']}');
            _setStatus(VouchStatus.idle);
            _startPolling();
        }
      } else {
        print('[VouchProvider] ❌ Server error: ${response.statusCode}');
        _setStatus(VouchStatus.error);
      }
    } catch (e) {
      print('[VouchProvider] ❌ Initial status check error: $e');
      _setStatus(VouchStatus.error);
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    print('[VouchProvider] 🔄 Starting polling timer');
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_status != VouchStatus.success) {
        _checkServerStatus();
      } else {
        print('[VouchProvider] ✅ Success achieved, stopping polling');
        _pollTimer?.cancel();
      }
    });
  }

  void _checkGeofenceStatus() async {
    if (_currentBusiness == null) return;

    // Don't check geofence if we already have a successful vouch
    if (_status == VouchStatus.success && _popToken != null) {
      print('[VouchProvider] ✅ Already have POP token, skipping geofence check');
      return;
    }

    print('[VouchProvider] 📍 Checking geofence status...');

    if (_locationProvider.currentLocation == null) {
      if (_isWaitingForLocation) {
        print('[VouchProvider] ⏳ Already waiting for location...');
        return;
      }

      _isWaitingForLocation = true;
      print('[VouchProvider] 📍 Requesting location...');

      await _locationProvider.getCurrentLocation();

      _isWaitingForLocation = false;

      if (_locationProvider.currentLocation == null) {
        print('[VouchProvider] ❌ Location still not available');
        _setStatus(VouchStatus.idle);
        return;
      }
    }

    final geofenceJson = _currentBusiness!.geofenceGeoJson;
    if (geofenceJson == null) {
      print('[VouchProvider] ❌ No geofence data');
      _setStatus(VouchStatus.error);
      return;
    }

    final userPoint = LatLng(
      _locationProvider.currentLocation!.latitude,
      _locationProvider.currentLocation!.longitude,
    );

    final bool isInside = _geofenceService.isPointInGeofence(userPoint, geofenceJson);

    print('[VouchProvider] 📍 User location: ${userPoint.latitude}, ${userPoint.longitude}');
    print('[VouchProvider] 🎯 Is inside geofence: $isInside');

    if (isInside) {
      _startServerTimer();
    } else {
      _setStatus(VouchStatus.outside);
    }
  }

  Future<void> _startServerTimer() async {
    if (_currentBusiness == null) return;
    final token = await _authService.getAuthToken();
    if (token == null) return;

    print('[VouchProvider] ⏱️ Starting server timer...');

    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/vouch/start'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'location_id': _currentBusiness!.id}),
      );
      print('[VouchProvider] ✅ Server timer started');
      _checkServerStatus();
    } catch (e) {
      print('[VouchProvider] ❌ Error starting timer: $e');
    }
  }

  Future<void> _stopServerTimer() async {
    if (_currentBusiness == null) return;
    final token = await _authService.getAuthToken();
    if (token == null) return;

    print('[VouchProvider] 🛑 Stopping server timer...');
    _setStatus(VouchStatus.vouching);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/vouch/stop'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'location_id': _currentBusiness!.id}),
      );

      print('[VouchProvider] 📡 Stop response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'completed') {
          _popToken = data['pop_token'];
          print('[VouchProvider] 🎉 Vouch completed! POP Token: $_popToken');
          _setStatus(VouchStatus.success);
          _pollTimer?.cancel();
          _rewardProvider.fetchRewards();
        } else {
          print('[VouchProvider] ⚠️ Vouch not completed: ${data['status']}');
          _setStatus(VouchStatus.outside);
        }
      }
    } catch (e) {
      print('[VouchProvider] ❌ Error stopping timer: $e');
      _setStatus(VouchStatus.error);
    }
  }

  Future<void> _checkServerStatus() async {
    if (_currentBusiness == null) return;

    // Don't check status if we already have success
    if (_status == VouchStatus.success && _popToken != null) {
      print('[VouchProvider] ✅ Already have success, stopping status checks');
      _pollTimer?.cancel();
      return;
    }

    final token = await _authService.getAuthToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/vouch/status/${_currentBusiness!.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        switch (data['status']) {
          case 'completed':
            _popToken = data['pop_token'];
            print('[VouchProvider] ✅ Status check - POP Token: $_popToken');
            _setStatus(VouchStatus.success);
            _pollTimer?.cancel();
            _rewardProvider.fetchRewards();
            break;

          case 'counting':
            _secondsRemaining = (data['seconds_remaining'] as num).toInt();
            _totalDwellTime = (data['dwell_time_total'] as num).toInt();

            if (_secondsRemaining <= 0) {
              await _stopServerTimer();
            } else {
              _setStatus(VouchStatus.counting);
              notifyListeners();
            }
            break;

          case 'idle':
            _checkGeofenceStatus();
            break;
        }
      }
    } catch (e) {
      print('[VouchProvider] ⚠️ Status check error: $e');
      // Don't set error status here, just continue polling
    }
  }

  void _setStatus(VouchStatus newStatus) {
    if (_status != newStatus) {
      print('[VouchProvider] 🔄 Status changed: $_status -> $newStatus');
      _status = newStatus;
      notifyListeners();
    }
  }
}