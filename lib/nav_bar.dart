import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:language_translator/constants.dart';
import 'package:language_translator/homepage.dart';
import 'package:language_translator/record_page.dart';
import 'package:language_translator/scan_to_text.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NBar extends StatefulWidget {
  const NBar({super.key});

  @override
  State<NBar> createState() => _NBarState();
}

class _NBarState extends State<NBar> {
  final _pageController = PageController(initialPage: 1);
  int _selectedIndex = 1;

  final List<Widget> _children = [
    const RecordPage(),
    const MyHomePage(),
    const ScanToText(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBackground,
      child: Scaffold(
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildFloatingNavbar(),
          ),
        ),
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false, // Let content handle keyboard
        body: Stack(
          children: [
            // Main Content
            PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: _children,
            ),

            // Floating Navbar
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavbar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color:
            const Color(0xFF1E1E2C).withOpacity(0.95), // Dark sleek background
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, LucideIcons.mic, "Voice"),
                _buildNavItem(1, LucideIcons.messageSquare, "Text"),
                _buildNavItem(2, LucideIcons.camera, "Camera"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _selectedIndex == index;

    return InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.white54,
                size: 24,
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                )
              ]
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, duration: 400.ms, curve: Curves.easeOut));
  }
}
