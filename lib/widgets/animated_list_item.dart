import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Stagger effect purely based on index delay
    // Using the user's requested syntax style: .animate().fade().scale()
    return child
        .animate(delay: (100 * index).ms)
        .fade(duration: 400.ms, curve: Curves.easeOut)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut);
  }
}
