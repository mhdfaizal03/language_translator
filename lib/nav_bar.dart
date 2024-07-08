import 'package:flutter/material.dart';
import 'package:language_translator/decoration.dart';
import 'package:language_translator/homepage.dart';
import 'package:language_translator/record_page.dart';
import 'package:language_translator/scan_to_text.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar_item.dart';

class NBar extends StatefulWidget {
  const NBar({super.key});

  @override
  State<NBar> createState() => _NBarState();
}

class _NBarState extends State<NBar> {
  final _pageControlller = PageController(initialPage: 1);

  final List<Widget> _children = [
    const RecordPage(),
    const MyHomePage(),
    const ScanToText(),
  ];

  @override
  Widget build(BuildContext context) {
    return StartBackgroundColor(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _pageControlller,
          children: _children,
        ),
        extendBody: true,
        bottomNavigationBar: RollingBottomBar(
          enableIconRotation: true,
          itemColor: Colors.black,
          color: Colors.white54,
          useActiveColorByDefault: false,
          controller: _pageControlller,
          flat: false,
          onTap: (index) {
            _pageControlller.animateToPage(
              index,
              duration: const Duration(seconds: 1),
              curve: Curves.decelerate,
            );
          },
          items: const [
            RollingBottomBarItem(
              Icons.record_voice_over_sharp,
              label: 'Record',
              activeColor: Colors.pink,
            ),
            RollingBottomBarItem(
              Icons.home,
              label: 'Home',
              activeColor: Colors.pink,
            ),
            RollingBottomBarItem(
              Icons.scanner,
              label: 'Scan',
              activeColor: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }
}
