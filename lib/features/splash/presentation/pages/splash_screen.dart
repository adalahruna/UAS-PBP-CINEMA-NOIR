// lib/features/splash/presentation/pages/splash_screen.dart

import 'dart:math'as math;

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  
  const SplashScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _curtainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _curtainAnimation;

  bool _showText = false;
  bool _showTagline = false;
  bool _showCurtain = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Fade animation untuk logo
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Scale animation untuk logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Curtain animation
    _curtainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _curtainAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _curtainController, curve: Curves.easeInOut),
    );
  }

  void _startSplashSequence() async {
    // Start fade and scale animations
    _fadeController.forward();
    _scaleController.forward();

    // Show cinema text after 800ms
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _showText = true;
      });
    }

    // Show tagline after 1500ms
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _showTagline = true;
      });
    }

    // Show curtain animation after 3000ms
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      setState(() {
        _showCurtain = true;
      });
      _curtainController.forward();
    }

    // Navigate to next screen
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _curtainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Film Icon
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildFilmReelIcon(),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Cinema Noir Text with shimmer
                if (_showText)
                  Shimmer.fromColors(
                    baseColor: AppColors.gold,
                    highlightColor: AppColors.textWhite,
                    period: const Duration(milliseconds: 2000),
                    child: const Text(
                      'Cinemanoir',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Animated Tagline
                if (_showTagline)
                  SizedBox(
                    height: 30,
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textGrey,
                        letterSpacing: 1.2,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'The show is about to begin...',
                            speed: const Duration(milliseconds: 80),
                          ),
                        ],
                        totalRepeatCount: 1,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 40),
                
                // Loading indicator
                if (_showTagline && !_showCurtain)
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                    ),
                  ),
              ],
            ),
          ),
          
          // Curtain effect overlay
          if (_showCurtain)
            AnimatedBuilder(
              animation: _curtainAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Left curtain
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      width: MediaQuery.of(context).size.width / 2,
                      child: Transform.translate(
                        offset: Offset(
                          -MediaQuery.of(context).size.width / 2 * _curtainAnimation.value,
                          0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                AppColors.darkBackground,
                                AppColors.darkBackground.withOpacity(0.95),
                              ],
                            ),
                          ),
                          child: CustomPaint(
                            painter: CurtainPainter(isLeft: true),
                          ),
                        ),
                      ),
                    ),
                    // Right curtain
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      width: MediaQuery.of(context).size.width / 2,
                      child: Transform.translate(
                        offset: Offset(
                          MediaQuery.of(context).size.width / 2 * _curtainAnimation.value,
                          0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppColors.darkBackground,
                                AppColors.darkBackground.withOpacity(0.95),
                              ],
                            ),
                          ),
                          child: CustomPaint(
                            painter: CurtainPainter(isLeft: false),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilmReelIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Film reel holes
          ...List.generate(8, (index) {
            final angle = (index * 45) * 3.14159 / 180;
            return Transform.translate(
              offset: Offset(
                35 * (math.cos(angle)),
                35 * (math.sin(angle)),
              ),
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold,
                  border: Border.all(
                    color: AppColors.darkBackground,
                    width: 2,
                  ),
                ),
              ),
            );
          }),
          
          // Center icon
          const Icon(
            Icons.movie_outlined,
            size: 50,
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }
}

// Custom painter untuk efek tirai
class CurtainPainter extends CustomPainter {
  final bool isLeft;
  
  CurtainPainter({required this.isLeft});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // Create wavy curtain effect
    for (var i = 0; i < size.height; i += 20) {
      if (isLeft) {
        path.moveTo(size.width, i.toDouble());
        path.quadraticBezierTo(
          size.width - 10,
          i + 10,
          size.width,
          i + 20,
        );
      } else {
        path.moveTo(0, i.toDouble());
        path.quadraticBezierTo(
          10,
          i + 10,
          0,
          i + 20,
        );
      }
    }
    
    canvas.drawPath(path, paint);
    
    // Draw vertical lines for curtain folds
    final linePaint = Paint()
      ..color = AppColors.gold.withOpacity(0.05)
      ..strokeWidth = 1;
    
    for (var i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        linePaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}