import 'package:flutter/material.dart';
import 'package:vouch/models/business_model.dart';
import 'package:vouch/app_theme.dart';

class BusinessCard extends StatelessWidget {
  final Business business;
  final double? distance;
  final VoidCallback onTap;

  const BusinessCard({
    super.key,
    required this.business,
    this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.primary.withOpacity(0.2), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack( // --- CHANGED Column to Stack ---
          children: [
            // Business Image (Bottom layer)
            Positioned.fill(
              child: business.imageUrl != null
                  ? Image.network(
                business.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.store, color: AppTheme.primary, size: 40),
                  );
                },
              )
                  : Container(
                color: Colors.grey[800],
                child: const Icon(Icons.store, color: AppTheme.primary, size: 40),
              ),
            ),

            // --- ADDED Gradient Fade ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120, // Adjust height of the fade
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // --- END OF Gradient ---

            // Text content (Top layer)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end, // Aligns to bottom
                  children: [
                    Text(
                      business.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // <-- Make text white
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.category, size: 14, color: Colors.grey[300]), // <-- Brighter
                        const SizedBox(width: 4),
                        Text(
                          business.category,
                          style: TextStyle(fontSize: 12, color: Colors.grey[300]), // <-- Brighter
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${business.rating}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // <-- Make text white
                              ),
                            ),
                          ],
                        ),
                        if (distance != null)
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: AppTheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                '${distance!.toStringAsFixed(1)} km',
                                style: const TextStyle(fontSize: 12, color: AppTheme.primary),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}