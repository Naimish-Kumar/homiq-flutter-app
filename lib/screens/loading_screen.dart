// lib/screens/loading_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../bloc/design/design_bloc.dart';
import '../theme/app_theme.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnim;
  late Animation<double> _rotateAnim;

  int _stepIndex = 0;
  final _steps = [
    ('Analyzing your room...', FontAwesomeIcons.magnifyingGlass),
    ('Applying design style...', FontAwesomeIcons.palette),
    ('Generating furniture layout...', FontAwesomeIcons.couch),
    ('Adding final touches...', FontAwesomeIcons.wandMagicSparkles),
    ('Almost ready!', FontAwesomeIcons.house),
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnim = Tween<double>(begin: 0, end: 1).animate(_rotateController);

    // Cycle through loading steps
    _cycleSteps();
  }

  void _cycleSteps() async {
    for (var i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() => _stepIndex = i);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DesignBloc, DesignState>(
      listener: (context, state) {
        if (state is DesignCompleted) {
          context.pushReplacement('/result', extra: state.design);
        } else if (state is DesignError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Decorative background glow
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Transform.scale(
                  scale: _pulseAnim.value,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.04),
                    ),
                  ),
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Spinning ring with logo
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _rotateAnim,
                            builder: (_, child) => Transform.rotate(
                              angle: _rotateAnim.value * 6.28,
                              child: child,
                            ),
                            child: CustomPaint(
                              size: const Size(120, 120),
                              painter: _ArcPainter(),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == .dark
                                  ? AppColors.surface
                                  : AppColors.surfaceL,
                              shape: .circle,
                              border: .all(color: AppColors.border),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const .all(16),
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: .contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Step title
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Row(
                        key: ValueKey(_stepIndex),
                        mainAxisAlignment: .center,
                        children: [
                          FaIcon(
                            _steps[_stepIndex].$2,
                            size: 20,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _steps[_stepIndex].$1,
                            style: AppTextStyles.headlineMedium,
                            textAlign: .center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Powered by Homiq AI',
                      style: AppTextStyles.bodyMedium,
                    ),

                    const SizedBox(height: 40),

                    // Step indicators
                    Row(
                      mainAxisAlignment: .center,
                      children: List.generate(_steps.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const .symmetric(horizontal: 4),
                          width: i == _stepIndex ? 24 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i <= _stepIndex
                                ? AppColors.primary
                                : Theme.of(context).brightness ==
                                      Brightness.dark
                                ? AppColors.surface
                                : AppColors.surfaceLight,
                            borderRadius: .circular(3),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 48),

                    Text(
                      'This usually takes 15–30 seconds',
                      style: AppTextStyles.caption,
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

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, -1.57, 2.5, false, paint);

    final paint2 = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawArc(rect, 1.0, 3.8, false, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
