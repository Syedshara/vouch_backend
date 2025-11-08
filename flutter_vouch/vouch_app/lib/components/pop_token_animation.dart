import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vouch/app_theme.dart';

class PopTokenAnimation extends StatefulWidget {
  final String popToken;
  final VoidCallback? onComplete;

  const PopTokenAnimation({
    super.key,
    required this.popToken,
    this.onComplete,
  });

  @override
  State<PopTokenAnimation> createState() => _PopTokenAnimationState();
}

class _PopTokenAnimationState extends State<PopTokenAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _bounceController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation (3D spin)
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotationAnimation = CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOutCubic,
    );

    // Scale animation (pop in effect)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Glow animation (pulsing light)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );

    // Particle animation (sparkles)
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    );

    // Bounce animation (3D bounce effect at the end)
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );

    // Start animations
    _scaleController.forward();
    _rotationController.forward();
    _particleController.forward();

    // Trigger bounce effect after rotation completes
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _bounceController.forward();
      }
    });

    // Call onComplete callback after all animations
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted && widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Widget _buildTokenCircle() {
    return Container(
      width: 220,
      height: 220,
      // <CHANGE> Circular token instead of shield shape
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            AppTheme.primary.withOpacity(1.0),
            AppTheme.primary.withOpacity(0.9),
            AppTheme.primary.withOpacity(0.8),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.6),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // <CHANGE> Glossy highlight effect on circle
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.7],
              ),
            ),
          ),
          // Token content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user,
                size: 80,
                color: Colors.white.withOpacity(0.95),
                shadows: const [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'POP TOKEN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.5,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: Stack(
          children: [
            // <CHANGE> Solid dull dark background overlay to hide content behind
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.75),
              ),
            ),
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Section - Success message
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _scaleAnimation.value.clamp(0.0, 1.0),
                        child: Column(
                          children: [
                            const Text(
                              '✓ Vouch Collected!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Proof-of-Presence Verified',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Middle Section - 3D Token with particles
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 350,
                      height: 350,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Animated particles/sparkles
                          AnimatedBuilder(
                            animation: _particleAnimation,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: List.generate(12, (index) {
                                  final angle = (index * 30.0) * (math.pi / 180);
                                  final distance = (140 * _particleAnimation.value).clamp(0.0, 200.0);
                                  final opacity = (1.0 - _particleAnimation.value).clamp(0.0, 1.0);

                                  return Transform.translate(
                                    offset: Offset(
                                      math.cos(angle) * distance,
                                      math.sin(angle) * distance,
                                    ),
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primary.withOpacity(0.6),
                                              blurRadius: 10,
                                              spreadRadius: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),

                          // Main 3D Token
                          AnimatedBuilder(
                            animation: Listenable.merge([
                              _rotationAnimation,
                              _scaleAnimation,
                              _glowAnimation,
                              _bounceAnimation,
                            ]),
                            builder: (context, child) {
                              // Calculate bounce offset for 3D effect
                              final bounceOffset = _bounceAnimation.value > 0
                                  ? math.sin(_bounceAnimation.value * math.pi) * 30
                                  : 0.0;

                              return Transform.scale(
                                scale: _scaleAnimation.value.clamp(0.0, 1.0),
                                child: Transform.translate(
                                  offset: Offset(0, -bounceOffset),
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001) // Perspective
                                      ..rotateY(_rotationAnimation.value * math.pi * 2),
                                    child: _buildTokenCircle(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Section - Token value
                Padding(
                  padding: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _scaleAnimation.value.clamp(0.0, 1.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primary.withOpacity(0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.25),
                                blurRadius: 25,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Token Generated',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.popToken,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace',
                                    letterSpacing: 1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You can now review this shop',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}