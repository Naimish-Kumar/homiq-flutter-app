import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/features/chat/presentation/screens/ai_chat_page.dart';
import 'package:homiq/features/history/presentation/screens/history_screen.dart';
import 'package:homiq/features/home/presentation/screens/home_screen.dart';
import 'package:homiq/features/profile/presentation/screens/profile_screen.dart';
import 'package:homiq/utils/guest_checker.dart';

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
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 85 + MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            color: context.color.primaryColor.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: context.color.brightness == Brightness.light
                    ? Colors.black.withValues(alpha: 0.04)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: Stack(
            children: [
              // Animated Indicator Background (Optional: can add a sliding glow here)
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _bottomItem(0, Icons.grid_view_rounded, 'Home'),
                    _bottomItem(1, Icons.auto_awesome_motion_rounded, 'Galleria'),
                    const SizedBox(width: 60),
                    _bottomItem(3, Icons.chat_bubble_rounded, 'AI Help'),
                    _bottomItem(4, Icons.person_rounded, 'Profile'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomItem(int index, IconData icon, String label) {
    final isSelected = currtab == index;
    return GestureDetector(
      onTap: () {
        if (currtab != index) {
          setState(() {
            currtab = index;
            pageController.jumpToPage(index);
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isSelected ? 1.2 : 1.0,
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? context.color.tertiaryColor
                    : context.color.textLightColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 6),
            CustomText(
              label.toUpperCase(),
              fontSize: 8,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              letterSpacing: 1,
              color: isSelected
                  ? context.color.tertiaryColor
                  : context.color.textLightColor.withValues(alpha: 0.6),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 4),
              width: isSelected ? 4 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: context.color.tertiaryColor,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: context.color.tertiaryColor.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      height: 68,
      width: 68,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.color.tertiaryColor,
            context.color.accentColor,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: context.color.tertiaryColor.withValues(alpha: 0.25),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: (){},
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
