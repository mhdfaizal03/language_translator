import 'package:flutter/material.dart';

class StartBackgroundColor extends StatelessWidget {
  Widget child;
  StartBackgroundColor({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
            Color.fromARGB(255, 38, 0, 255),
            Color.fromARGB(115, 255, 0, 0)
          ])),
      child: child,
    );
  }
}
