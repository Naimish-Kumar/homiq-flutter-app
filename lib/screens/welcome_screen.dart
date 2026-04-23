import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Image with Arch and Chair
          Positioned.fill(
            child: Image.asset('assets/welcome_bg.png', fit: .cover),
          ),

          // Subtle Gradient overlay for text readability if needed
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.background.withValues(alpha: 0.5),
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.8),
                  ],
                  begin: .topCenter,
                  end: .bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20,
              ),
              child: Column(
                children: [
                  // Top Text Section
                  const SizedBox(height: 20),
                  Text(
                    'Design\nYour Dream Space',
                    textAlign: .center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Beautiful interiors, personalized\nfor you.',
                    textAlign: .center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Center Logo
                  Image.asset(
                    'assets/logo.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),

                  const Spacer(flex: 3),

                  // Bottom Text Section
                  Text(
                    'Interior Design,\nMade Personal',
                    textAlign: .center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: .w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Get inspired, plan smart and create\nspaces that reflect you.',
                    textAlign: .center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: .w400,
                      color: AppColors.textSecondary,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Action Buttons
                  PrimaryButton(
                    label: 'Get Started',
                    onPressed: () => context.push('/login'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
