import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:language_translator/constants.dart';
import 'package:language_translator/nav_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to NBar after animation
    Future.delayed(const Duration(milliseconds: 3000), () {
      Get.off(() => const NBar(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 800));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F3460), // Deep Blue
              Color(0xFF16213E), // Darker Navy
              Color.fromARGB(255, 23, 3, 59), // Purple Accent
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Animation
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white24, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.9),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: const Icon(
                  LucideIcons.languages,
                  size: 80,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 600.ms)
                  .shimmer(
                      delay: 1000.ms, duration: 1500.ms, color: Colors.white54),

              const SizedBox(height: 40),

              // Title Animation
              Text(
                "TransVerse",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: AppColors.primary.withOpacity(0.9),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 800.ms).moveY(
                  begin: 20, end: 0, duration: 800.ms, curve: Curves.easeOut),

              const SizedBox(height: 10),

              // Subtitle Animation
              const Text(
                "Breaking Language Barriers",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                  letterSpacing: 4,
                ),
              ).animate().fadeIn(delay: 1000.ms, duration: 800.ms),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
