// lib/components/scratch_card_modal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/scratcher.dart';
import 'package:confetti/confetti.dart';
import 'package:vouch/providers/reward_provider.dart';
import 'package:vouch/app_theme.dart';

class ScratchCardModal extends StatefulWidget {
  final Reward reward;
  const ScratchCardModal({super.key, required this.reward});

  @override
  State<ScratchCardModal> createState() => _ScratchCardModalState();
}

class _ScratchCardModalState extends State<ScratchCardModal>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _revealController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool isRevealed = false;
  final scratchKey = GlobalKey<ScratcherState>();

  @override
  void initState() {
    super.initState();

    // Professional minimalistic confetti
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 2000),
    );

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Smooth elastic scale animation for enchanted feel
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: Curves.elasticOut,
      ),
    );

    // Smooth fade in
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Gentle slide up
    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _revealController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _autoRevealCard() {
    if (!isRevealed) {
      scratchKey.currentState?.reveal();

      setState(() {
        isRevealed = true;
      });

      // Slight delay for polished celebration
      Future.delayed(const Duration(milliseconds: 150), () {
        _confettiController.play();
        _revealController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeHeight = screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Dark overlay
        Container(
          color: Colors.black.withOpacity(0.7),
        ),

        // Main dialog
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: safeHeight * 0.8,
              maxWidth: screenWidth - 40,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Caption at top
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.9),
                        AppTheme.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Scratch to Reveal Your Gift',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Scratch card with proper constraints
                Flexible(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Scratcher(
                        key: scratchKey,
                        brushSize: 50,
                        threshold: 60,
                        color: Colors.grey[850]!,
                        onChange: (value) {
                          // Optional: Show progress
                        },
                        onThreshold: () {
                          _autoRevealCard();
                        },
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.surface,
                                  AppTheme.surface.withOpacity(0.95),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Success icon with shimmer animation
                                AnimatedBuilder(
                                  animation: _revealController,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, _slideAnimation.value),
                                      child: Opacity(
                                        opacity: _fadeAnimation.value,
                                        child: Transform.scale(
                                          scale: _scaleAnimation.value,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Outer glow ring
                                              Container(
                                                width: 90,
                                                height: 90,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: RadialGradient(
                                                    colors: [
                                                      AppTheme.primary.withOpacity(0.0),
                                                      AppTheme.primary.withOpacity(0.3),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Inner circle
                                              Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primary.withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppTheme.primary.withOpacity(0.4),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.check_circle_rounded,
                                                  color: AppTheme.primary,
                                                  size: 42,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Congratulations text
                                AnimatedBuilder(
                                  animation: _fadeAnimation,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _fadeAnimation.value,
                                      child: const Text(
                                        "Congratulations!",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                          letterSpacing: 1,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Reward title with shimmer effect
                                AnimatedBuilder(
                                  animation: _revealController,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, _slideAnimation.value),
                                      child: Opacity(
                                        opacity: _fadeAnimation.value,
                                        child: Transform.scale(
                                          scale: _scaleAnimation.value,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 18,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppTheme.primary.withOpacity(0.25),
                                                  AppTheme.primary.withOpacity(0.08),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: AppTheme.primary.withOpacity(0.5),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.primary.withOpacity(0.2),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              widget.reward.title,
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w900,
                                                color: AppTheme.primary,
                                                letterSpacing: 0.5,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 12),

                                // Business name
                                AnimatedBuilder(
                                  animation: _fadeAnimation,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _fadeAnimation.value,
                                      child: Text(
                                        widget.reward.business,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[400],
                                          letterSpacing: 0.3,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Action button
                                AnimatedBuilder(
                                  animation: _fadeAnimation,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _fadeAnimation.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primary.withOpacity(0.4),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () => Navigator.of(context).pop(),
                                          icon: const Icon(Icons.wallet_rounded, size: 19),
                                          label: const Text(
                                            'Add to Wallet',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                              horizontal: 28,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Professional minimalistic confetti from bottom
        Align(
          alignment: Alignment.bottomCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -3.14 / 2, // Upward
            blastDirectionality: BlastDirectionality.directional,
            particleDrag: 0.03,
            emissionFrequency: 0.02,
            numberOfParticles: 15,
            gravity: 0.1,
            shouldLoop: false,
            maxBlastForce: 15,
            minBlastForce: 8,
            colors: [
              AppTheme.primary,
              AppTheme.primary.withOpacity(0.8),
              Colors.white.withOpacity(0.9),
              Colors.blue.shade300,
            ],
          ),
        ),

        // Subtle side sparkles for enchanted effect
        Positioned(
          left: 20,
          top: MediaQuery.of(context).size.height * 0.4,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 0, // Right
            blastDirectionality: BlastDirectionality.directional,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 8,
            gravity: 0.05,
            shouldLoop: false,
            maxBlastForce: 10,
            minBlastForce: 5,
            colors: [
              AppTheme.primary.withOpacity(0.7),
              Colors.white.withOpacity(0.6),
            ],
          ),
        ),

        // Subtle side sparkles from right
        Positioned(
          right: 20,
          top: MediaQuery.of(context).size.height * 0.4,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14, // Left
            blastDirectionality: BlastDirectionality.directional,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 8,
            gravity: 0.05,
            shouldLoop: false,
            maxBlastForce: 10,
            minBlastForce: 5,
            colors: [
              AppTheme.primary.withOpacity(0.7),
              Colors.white.withOpacity(0.6),
            ],
          ),
        ),
      ],
    );
  }
}