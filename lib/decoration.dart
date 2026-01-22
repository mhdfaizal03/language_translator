import 'package:flutter/material.dart';
import 'package:language_translator/constants.dart';

class StartBackgroundColor extends StatelessWidget {
  final Widget child;
  const StartBackgroundColor({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBackground,
      child: child,
    );
  }
}
