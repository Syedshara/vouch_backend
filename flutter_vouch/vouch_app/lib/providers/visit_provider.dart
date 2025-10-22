import 'package:flutter/material.dart';

class Visit {
  final String id;
  final String businessName;
  final String location;
  final DateTime visitDate;
  final String vouchType; // 'automatic' or 'manual'
  final String? qrCode;

  Visit({
    required this.id,
    required this.businessName,
    required this.location,
    required this.visitDate,
    required this.vouchType,
    this.qrCode,
  });
}

class VisitProvider with ChangeNotifier {
  final List<Visit> _visits = [
    Visit(
      id: '1',
      businessName: 'Annapoorna Gowrishankar',
      location: 'RS Puram, Coimbatore',
      visitDate: DateTime.now().subtract(const Duration(days: 5)),
      vouchType: 'automatic',
    ),
    Visit(
      id: '2',
      businessName: 'Brookfields Mall',
      location: 'Gandhipuram, Coimbatore',
      visitDate: DateTime.now().subtract(const Duration(days: 10)),
      vouchType: 'automatic',
    ),
    Visit(
      id: '3',
      businessName: 'The French Door',
      location: 'Peelamedu, Coimbatore',
      visitDate: DateTime.now().subtract(const Duration(days: 15)),
      vouchType: 'manual',
    ),
  ];

  List<Visit> get visits => _visits;

  void addVisit(Visit visit) {
    _visits.insert(0, visit);
    notifyListeners();
  }

  void addManualVouch(String businessName, String location) {
    final visit = Visit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      businessName: businessName,
      location: location,
      visitDate: DateTime.now(),
      vouchType: 'manual',
      qrCode: 'QR_${DateTime.now().millisecondsSinceEpoch}',
    );
    addVisit(visit);
  }
}
