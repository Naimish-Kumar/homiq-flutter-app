import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/ui/screens/home/home_screen.dart';
import 'package:homiq/ui/screens/userprofile/profile_screen.dart';

class MainActivity extends StatefulWidget {
  const MainActivity({required this.from, super.key});
  final String from;

  @override
  State<MainActivity> createState() => MainActivityState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map? ?? {};
    return CupertinoPageRoute(
      builder: (_) => MainActivity(from: arguments['from'] as String? ?? 'main'),
    );
  }
}

class MainActivityState extends State<MainActivity> {
  int currtab = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    GuestChecker.setContext(context);
    
    // Switch tab if requested via arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
      if (arguments != null && arguments.containsKey('tab')) {
        final targetTab = arguments['tab'] as int;
        if (targetTab < pages.length) {
          setState(() {
            currtab = targetTab;
            pageController.jumpToPage(targetTab);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  late List<Widget> pages = [
    HomeScreen(from: widget.from),
    const HistoryScreen(), // Implemented Design History
    const SizedBox.shrink(), // Center button placeholder
    const AIChatPage(), // Implemented AI Assistant
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Key for glassmorphism
      backgroundColor: context.color.primaryColor,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 85 + MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            color: context.color.primaryColor.withOpacity(0.85),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomItem(0, Icons.home_filled, 'Home'),
                _bottomItem(1, Icons.auto_awesome_motion_rounded, 'Galleria'),
                const SizedBox(width: 60), // Space for larger FAB
                _bottomItem(3, Icons.chat_bubble_rounded, 'AI Help'),
                _bottomItem(4, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomItem(int index, IconData icon, String label) {
    final isSelected = currtab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          currtab = index;
          pageController.jumpToPage(index);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? context.color.tertiaryColor : context.color.textLightColor,
            ),
            const SizedBox(height: 6),
            CustomText(
              label.toUpperCase(),
              fontSize: 8,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              letterSpacing: 1,
              color: isSelected ? context.color.tertiaryColor : context.color.textLightColor,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: context.color.tertiaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.color.tertiaryColor.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        color: context.color.tertiaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: context.color.tertiaryColor.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.designStudio),
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}
