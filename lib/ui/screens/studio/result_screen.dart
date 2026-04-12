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
      initialChildSize: 0.08,
      minChildSize: 0.08,
      maxChildSize: 0.45,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: Colors.white12),
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
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          'SHOP THE LOOK',
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.color.tertiaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomText(
                            'AI SUGGESTIONS',
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: context.color.tertiaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
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
                  const SizedBox(height: 30),
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
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: CustomImage(imageUrl: img, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  name,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  maxLines: 1,
                  color: Colors.white,
                ),
                const SizedBox(height: 2),
                CustomText(
                  price,
                  fontSize: 12,
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
              left: constraints.maxWidth * _sliderValue - 2,
              top: 0,
              bottom: 0,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: context.color.tertiaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: context.color.tertiaryColor.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    child: Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.unfold_more_outlined,
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
              bottom: 160,
              left: 24,
              child: _label('BASE VIEW', Colors.black45),
            ),
            Positioned(
              bottom: 160,
              right: 24,
              child: _label('AI CONCEPT', context.color.tertiaryColor),
            ),
          ],
        );
      },
    );
  }

  Widget _label(String text, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: color.withOpacity(0.7),
          child: CustomText(
            text,
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
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

  Widget _circleIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black26,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40,
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.color.tertiaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.auto_awesome_rounded,
                          color: context.color.tertiaryColor, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            widget.result['style']?['name']?.toString().toUpperCase() ??
                                "AI PREVIEW",
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: context.color.tertiaryColor,
                          ),
                          const CustomText(
                            'Conceptual Design Ready',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                        icon: Icons.bookmark_add_rounded,
                        label: 'SAVE CONCEPT',
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
        height: 56,
        decoration: BoxDecoration(
          color: isPrimary ? context.color.tertiaryColor : Colors.white10,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: context.color.tertiaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            CustomText(
              label,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.5,
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
