import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth/auth_bloc.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particleController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    // Logo entrance
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Text entrance
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Particle burst
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _textFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _logoController.forward().then((_) {
      _particleController.forward();
      _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) context.go('/home');
          });
        } else if (state is AuthUnauthenticated) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) context.go('/welcome');
          });
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const MeshGradient(),

            // Particles
            Center(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, _) => CustomPaint(
                  size: const Size(400, 400),
                  painter: _ParticlePainter(
                    progress: _particleController.value,
                    isDark: isDark,
                  ),
                ),
              ),
            ),

            // Content
            Center(
              child: Column(
                mainAxisSize: .min,
                children: [
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) => FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(scale: _logoScale, child: child),
                    ),
                    child: Container(
                      width: 300,

                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    'VIRTUAL INTERIOR DESIGNER',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryL,
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(
                  children: [
                    Text(
                      'AI Powering Your Space',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.textMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 40,
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        backgroundColor: isDark
                            ? Colors.white10
                            : Colors.black12,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _ParticlePainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final center = size.center(Offset.zero);
    final rng = Random(42);
    const count = 16;

    for (var i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi + rng.nextDouble() * 0.5;
      final distance = 80 + rng.nextDouble() * 100;
      final pProgress = (progress * 1.5 - i * 0.02).clamp(0.0, 1.0);
      final opacity = (1.0 - pProgress).clamp(0.0, 1.0);

      final dx = center.dx + cos(angle) * distance * pProgress;
      final dy = center.dy + sin(angle) * distance * pProgress;
      final radius = (2 + rng.nextDouble() * 2) * (1 - pProgress * 0.5);

      final color = AppColors.primary.withValues(alpha: opacity * 0.6);
      canvas.drawCircle(Offset(dx, dy), radius, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress;
}
