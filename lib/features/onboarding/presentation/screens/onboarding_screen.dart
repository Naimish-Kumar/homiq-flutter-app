import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:homiq/app/routes.dart';
import 'package:homiq/utils/extensions/extensions.dart';
import 'package:homiq/utils/app_icons.dart' show AppIcons;
import 'package:homiq/utils/custom_image.dart';
import 'package:homiq/utils/extensions/lib/custom_text.dart';
import 'package:homiq/utils/responsive_size.dart';
import 'package:homiq/utils/ui_utils.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int currentPageIndex = 0;
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slidersList = [
      {
        'image': 'assets/onboarding/onboarding_1.png',
        'title': 'Bright Living',
        'subtitle': 'CLEAN LUXURY SPACES',
        'description':
            'Experience the beauty of Scandinavian minimalism. Curate spaces that are bright, airy, and effortlessly sophisticated.',
        'color': context.color.tertiaryColor,
      },
      {
        'image': 'assets/onboarding/onboarding_2.png',
        'title': 'Tailored Styles',
        'subtitle': 'CURATE YOUR AESTHETIC',
        'description':
            'From Mid-Century Modern to Industrial Loft. Discover the styles that resonate with your personality.',
        'color': context.color.tertiaryColor,
      },
      {
        'image': 'assets/onboarding/onboarding_3.png',
        'title': 'High Fidelity',
        'subtitle': 'PROFESSIONAL RESULTS',
        'description':
            'Get professional-grade renderings instantly. Visualize every detail with unparalleled clarity and realism.',
        'color': context.color.tertiaryColor,
      },
    ];

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        body: Stack(
          children: [
            // Modern Animated Rose Gold Mesh Background
            Container(
              decoration: BoxDecoration(
                gradient: context.color.meshGradient,
              ),
            ),
            // Floating Decorative Glows
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.color.tertiaryColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -150,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.color.accentColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildTopBar(context),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            currentPageIndex = index;
                          });
                        },
                        itemCount: slidersList.length,
                        itemBuilder: (context, index) {
                          return _buildOnboardingPage(
                            context,
                            slidersList[index],
                            index,
                          );
                        },
                      ),
                    ),
                    _buildBottomSection(context, slidersList.length),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Hero(
            tag: 'splash_logo',
            child: SizedBox(
              height: 48.rh(context),
              child: CustomImage(
                imageUrl: AppIcons.splashLogo,
                fit: BoxFit.contain,
              ),
            ),
          ),
          _buildSkipButton(context),
        ],
      ),
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, Routes.login);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.color.tertiaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: CustomText(
              'SKIP',
              color: context.color.textColorDark,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
    BuildContext context,
    Map<String, dynamic> data,
    int index,
  ) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.5)).clamp(0, 1.0);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Premium Hero Image with Parallax
              Expanded(
                flex: 10,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 20, bottom: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: context.color.tertiaryColor.withValues(alpha: 0.15),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Transform.scale(
                          scale: 1.1,
                          child: Transform.translate(
                            offset: Offset(
                              (_pageController.position.haveDimensions
                                      ? (_pageController.page! - index)
                                      : 0) *
                                  100,
                              0,
                            ),
                            child: Image.asset(
                              data['image'] as String,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Luxury Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 0.8),
                              ],
                              stops: const [0.5, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Glassmorphic Content Section
              Expanded(
                flex: 5,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 40),
                  child: Opacity(
                    opacity: value,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: context.color.tertiaryColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: context.color.tertiaryColor.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: CustomText(
                            data['subtitle']?.toString() ?? '',
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                            letterSpacing: 4,
                            color: context.color.tertiaryColor,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 28),
                        CustomText(
                          data['title']?.toString() ?? '',
                          fontWeight: FontWeight.w400,
                          fontSize: 36,
                          color: context.color.textColorDark,
                          textAlign: TextAlign.center,
                          useSerif: true,
                          letterSpacing: -0.5,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: CustomText(
                            data['description']?.toString() ?? '',
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            fontSize: 15,
                            color: context.color.textLightColor,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(BuildContext context, int totalPages) {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              totalPages,
              (index) => _buildIndicator(context, index == currentPageIndex),
            ),
          ),
          _buildNextButton(context, totalPages),
        ],
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(right: 10),
      height: 6,
      width: isActive ? 32 : 12,
      decoration: BoxDecoration(
        color: isActive
            ? context.color.tertiaryColor
            : context.color.tertiaryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        boxShadow: isActive ? [
          BoxShadow(
            color: context.color.tertiaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
          )
        ] : null,
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, int totalPages) {
    final bool isLastPage = currentPageIndex == totalPages - 1;
    return GestureDetector(
      onTap: () {
        if (!isLastPage) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuart,
          );
        } else {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.login, (route) => false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: isLastPage ? 200 : 76,
        height: 76,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.color.tertiaryColor,
              context.color.accentColor,
            ],
          ),
          borderRadius: BorderRadius.circular(38),
          boxShadow: [
            BoxShadow(
              color: context.color.tertiaryColor.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isLastPage
                ? const CustomText(
                    'GET STARTED',
                    key: ValueKey('start'),
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 3,
                  )
                : const Icon(
                    Icons.arrow_forward_ios_rounded,
                    key: ValueKey('next'),
                    color: Colors.white,
                    size: 24,
                  ),
          ),
        ),
      ),
    );
  }
}
