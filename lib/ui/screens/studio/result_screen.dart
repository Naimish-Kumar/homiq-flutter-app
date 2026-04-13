import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:share_plus/share_plus.dart';

class DesignResultScreen extends StatefulWidget {
  const DesignResultScreen({required this.result, this.original, super.key});
  final Map<String, dynamic> result;
  final File? original;

  @override
  State<DesignResultScreen> createState() => DesignResultScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => DesignResultScreen(
        result: args?['result'] as Map<String, dynamic>,
        original: args?['original'] as File?,
      ),
    );
  }
}

class DesignResultScreenState extends State<DesignResultScreen> {
  double _sliderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Comparison Area
          _buildComparisonSlider(),

          // Overlays
          _buildTopBar(),
          _buildBottomControls(),
          _buildDiscoveryTray(),
        ],
      ),
    );
  }

  Widget _buildDiscoveryTray() {
    return DraggableScrollableSheet(
      initialChildSize: 0.1,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(40)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              'SHOP THE CONCEPT',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white60,
                              letterSpacing: 2,
                            ),
                            SizedBox(height: 4),
                            CustomText(
                              'Suggested Elements',
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              useSerif: true,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: context.color.tertiaryColor
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: context.color.tertiaryColor
                                    .withValues(alpha: 0.3)),
                          ),
                          child: CustomText(
                            'AI CURATED',
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: context.color.tertiaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _furnitureCard(
                          'Velvet Accent Sofa',
                          r'$1,249',
                          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400',
                        ),
                        _furnitureCard(
                          'Minimalist Floor Lamp',
                          r'$189',
                          'https://images.unsplash.com/photo-1507473885765-e6ed657f99ad?w=400',
                        ),
                        _furnitureCard(
                          'Nordic Oak Table',
                          r'$450',
                          'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?w=400',
                        ),
                        _furnitureCard(
                          'Abstract Wall Art',
                          r'$120',
                          'https://images.unsplash.com/photo-1541963463532-d68292c34b19?w=400',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _furnitureCard(String name, String price, String img) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: CustomImage(
                  imageUrl: img, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  name,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 4),
                CustomText(
                  price,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: context.color.tertiaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSlider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Original Image (Background)
            if (widget.original != null)
              Image.file(
                widget.original!,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),

            // Transformed Image (Clipped Overlay)
            ClipPath(
              clipper: _BeforeAfterClipper(_sliderValue),
              child: CustomImage(
                imageUrl: widget.result['result_image_url'] as String,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),

            // Interaction Overlay
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _sliderValue =
                      (details.localPosition.dx / constraints.maxWidth).clamp(
                        0.0,
                        1.0,
                      );
                });
              },
              child: Container(color: Colors.transparent),
            ),

            // Divider Line & Handle
            Positioned(
              left: constraints.maxWidth * _sliderValue - 1,
              top: 0,
              bottom: 0,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: context.color.tertiaryColor.withValues(alpha: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: context.color.tertiaryColor
                              .withValues(alpha: 0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: context.color.tertiaryColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          color: context.color.tertiaryColor,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Comparison Labels
            Positioned(
              bottom: 200,
              left: 24,
              child: _label('ORIGINAL', Colors.black45),
            ),
            Positioned(
              bottom: 200,
              right: 24,
              child: _label('REIMAGINED', context.color.tertiaryColor),
            ),
          ],
        );
      },
    );
  }

  Widget _label(String text, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: CustomText(
            text,
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          _circleIconButton(
            icon: Icons.share_rounded,
            onTap: () => Share.share(
              'Reimagined my room with Homiq AI! See the transformation: ${widget.result['result_image_url']}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 60,
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            context.color.tertiaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(Icons.auto_awesome_rounded,
                          color: context.color.tertiaryColor, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            widget.result['style']?['name']
                                    ?.toString()
                                    .toUpperCase() ??
                                "DESIGN",
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: context.color.tertiaryColor,
                          ),
                          const SizedBox(height: 4),
                          const CustomText(
                            'CONCEPT FINALIZED',
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            useSerif: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        onTap: () => Navigator.pop(context),
                        icon: Icons.refresh_rounded,
                        label: 'REDESIGN',
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _actionButton(
                        onTap: () {
                          HelperUtils.showSnackBarMessage(
                              context, 'Design saved to your history!');
                        },
                        icon: Icons.bookmark_added_rounded,
                        label: 'SAVE',
                        isPrimary: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isPrimary
              ? context.color.tertiaryColor
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: context.color.tertiaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              : [],
          border: isPrimary
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            CustomText(
              label,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _BeforeAfterClipper extends CustomClipper<Path> {
  _BeforeAfterClipper(this.value);
  final double value;

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(
        Rect.fromLTWH(
          size.width * value,
          0,
          size.width * (1 - value),
          size.height,
        ),
      );
  }

  @override
  bool shouldReclip(_BeforeAfterClipper oldClipper) => oldClipper.value != value;
}
