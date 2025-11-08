import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vouch/app_theme.dart';

class Top10Carousel extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;
  // --- FIX 1: Changed the function type ---
  // FROM: final VoidCallback? onItemTap;
  // TO:
  final void Function(int index)? onItemTap;

  const Top10Carousel({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) { // <-- 'index' is available here
              final item = items[index];
              return FadeInRight(
                delay: Duration(milliseconds: 50 * index),
                child: GestureDetector(
                  // --- FIX 2: Call the function with the index ---
                  // FROM: onTap: onItemTap,
                  // TO:
                  onTap: () => onItemTap?.call(index),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    clipBehavior: Clip.antiAlias, // <-- ADD THIS
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.surface, // Fallback color
                      image: item['image'] != null
                          ? DecorationImage(
                        image: NetworkImage(item['image']!),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {},
                      )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        if (item['image'] == null)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primary.withOpacity(0.8),
                                  AppTheme.primary.withOpacity(0.4),
                                ],
                              ),
                            ),
                          ),

                        // --- ADDED Gradient Fade ---
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 100, // Adjust height of the fade
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

                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  // Use a darker, more subtle background
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '#${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          size: 12, color: Colors.yellow[300]),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['rating'] ?? '4.5',
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}