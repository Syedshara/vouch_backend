import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/scratcher.dart';
import 'package:confetti/confetti.dart';
import 'package:vouch_app/providers/reward_provider.dart';
import 'package:vouch_app/app_theme.dart';

class ScratchCardModal extends StatefulWidget {
  final Reward reward;
  const ScratchCardModal({super.key, required this.reward});

  @override
  State<ScratchCardModal> createState() => _ScratchCardModalState();
}

class _ScratchCardModalState extends State<ScratchCardModal> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _revealController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  bool isRevealed = false;
  final scratchKey = GlobalKey<ScratcherState>();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _revealController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _autoRevealCard() {
    if (!isRevealed) {
      // Force full reveal of the scratcher
      scratchKey.currentState?.reveal();

      // Play animations
      _confettiController.play();
      _revealController.forward();
      _bounceController.forward();

      // Claim the reward
      context.read<RewardProvider>().claimNotification(widget.reward.id);
      setState(() { isRevealed = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              height: 380,
              width: double.infinity,
              child: Scratcher(
                key: scratchKey,
                brushSize: 60,
                threshold: 50,
                color: Colors.grey[900]!,
                onThreshold: () {
                  _autoRevealCard();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.surface.withOpacity(0.95),
                        AppTheme.surface.withOpacity(0.85),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.primary.withOpacity(0.15),
                                AppTheme.primary.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _fadeAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Transform.scale(
                                    scale: 0.8 + (_scaleAnimation.value * 0.2),
                                    child: child,
                                  ),
                                );
                              },
                              child: const Text(
                                "🎉 Congratulations!",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                            AnimatedBuilder(
                              animation: Listenable.merge([_scaleAnimation, _bounceAnimation]),
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value * _bounceAnimation.value,
                                  child: child,
                                );
                              },
                              child: ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    AppTheme.primary,
                                    AppTheme.primary.withOpacity(0.7),
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  widget.reward.title,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.reward.business,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[400],
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 32,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Add to Wallet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          particleDrag: 0.05,
          emissionFrequency: 0.05,
          numberOfParticles: 50,
          gravity: 0.1,
        ),
      ],
    );
  }
}
