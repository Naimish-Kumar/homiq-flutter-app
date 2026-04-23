// lib/screens/result/result_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/design/design_bloc.dart';
import '../../models/design_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ResultScreen extends StatefulWidget {
  final DesignModel design;
  const ResultScreen({super.key, required this.design});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  double _sliderValue = 0.5;
  late AnimationController _enterController;
  late Animation<double> _enterFade;
  late Animation<Offset> _enterSlide;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _enterFade = CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: AppCurves.defaultCurve,
    ));
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  void _saveDesign() {
    context.read<DesignBloc>().add(DesignSave(designId: widget.design.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
            const SizedBox(width: 12),
            Text('Design saved to your library!', 
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _shareDesign() async {
    final imageUrl = widget.design.generatedImagePath ?? widget.design.originalImagePath;
    final shareText = 'Check out my AI-redesigned room with Homiq AI!\n\nStyle: ${widget.design.styleLabel}\nBudget: ${widget.design.budgetLabel}';
    
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/homiq_design_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles([XFile(file.path)], text: shareText);
      } else {
        await Share.share(shareText);
      }
    } catch (e) {
      await Share.share(shareText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final design = widget.design;
    final hasGenerated = design.generatedImagePath != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: isDark ? Colors.white : AppColors.textPrimaryL),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Your Masterpiece',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: isDark ? Colors.white : AppColors.textPrimaryL,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: BlocBuilder<DesignBloc, DesignState>(
              builder: (context, state) {
                final saved =
                    state is DesignCompleted && state.design.isFavorite ||
                        design.isFavorite;
                return Icon(
                  saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: saved ? AppColors.primary : (isDark ? Colors.white : AppColors.textPrimaryL),
                );
              },
            ),
            onPressed: _saveDesign,
          ),
          IconButton(
            icon: Icon(Icons.share_rounded,
                color: isDark ? Colors.white : AppColors.textPrimaryL),
            onPressed: _shareDesign,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          const MeshGradient(),
          FadeTransition(
            opacity: _enterFade,
            child: SlideTransition(
              position: _enterSlide,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  
                  // Tags
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          FeatureBadge(
                            label: design.styleLabel,
                            icon: design.styleIcon,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          FeatureBadge(
                            label: design.budgetLabel,
                            icon: design.budgetIcon,
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Image Comparison
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: hasGenerated
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.compare_rounded, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Before & After',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : AppColors.textPrimaryL,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _BeforeAfterSlider(
                                  beforeUrl: design.originalImagePath,
                                  afterUrl: design.generatedImagePath!,
                                  sliderValue: _sliderValue,
                                  onSliderChanged: (v) =>
                                      setState(() => _sliderValue = v),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.network(
                                design.originalImagePath,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 320,
                              ),
                            ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // AI Summary
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'AI Insight',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppColors.textPrimaryL,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(color: Colors.white10),
                            ),
                            _SummaryRow(
                              label: 'Space Category',
                              value: design.roomType,
                              icon: Icons.meeting_room_rounded,
                            ),
                            const SizedBox(height: 12),
                            _SummaryRow(
                              label: 'Selected Style',
                              value: design.styleLabel,
                              icon: design.styleIcon,
                            ),
                            const SizedBox(height: 12),
                            _SummaryRow(
                              label: 'Budget Tier',
                              value: design.budgetLabel,
                              icon: design.budgetIcon,
                            ),
                            const SizedBox(height: 12),
                            _SummaryRow(
                              label: 'Est. Investment',
                              value: design.budgetRange,
                              icon: Icons.currency_rupee_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // Recommendations
                  if (design.furnitureRecommendations.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_bag_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Shop the Look',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textPrimaryL,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 240,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: design.furnitureRecommendations.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, i) => _FurnitureCard(
                            item: design.furnitureRecommendations[i],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),

                  // Bottom Actions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          PrimaryButton(
                            label: 'Share Results',
                            onPressed: _shareDesign,
                            icon: Icons.share_rounded,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: OutlinedButton(
                              onPressed: () {
                                context.read<DesignBloc>().add(DesignReset());
                                context.go('/home');
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDark ? Colors.white12 : Colors.black12,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              child: Text(
                                'Design Another Space',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textPrimaryL,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final dynamic icon;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryL,
          ),
        ),
        Row(
          children: [
            if (icon != null) ...[
              SmartIcon(icon, size: 14, color: valueColor ?? AppColors.primary),
              const SizedBox(width: 8),
            ],
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor ?? (isDark ? Colors.white : AppColors.textPrimaryL),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BeforeAfterSlider extends StatelessWidget {
  final String beforeUrl;
  final String afterUrl;
  final double sliderValue;
  final ValueChanged<double> onSliderChanged;

  const _BeforeAfterSlider({
    required this.beforeUrl,
    required this.afterUrl,
    required this.sliderValue,
    required this.onSliderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final splitX = width * sliderValue;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(afterUrl, fit: BoxFit.cover),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: splitX,
                      child: ClipRect(
                        child: Image.network(
                          beforeUrl,
                          fit: BoxFit.cover,
                          width: width,
                        ),
                      ),
                    ),
                    Positioned(
                      left: splitX - 1.5,
                      top: 0,
                      bottom: 0,
                      width: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: splitX - 22,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.unfold_more_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: _Label('ORIGINAL'),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: _Label('REDESIGNED'),
                    ),
                    Positioned.fill(
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          onSliderChanged((details.localPosition.dx / width).clamp(0.0, 1.0));
                        },
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: Colors.white10,
            thumbShape: SliderComponentShape.noThumb,
            trackHeight: 4,
          ),
          child: Slider(
            value: sliderValue,
            onChanged: onSliderChanged,
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _FurnitureCard extends StatelessWidget {
  final FurnitureItem item;
  const _FurnitureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () async {
        final url = item.affiliateUrl ?? item.shopUrl;
        if (url.isNotEmpty) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1),
                      child: const Center(child: Icon(Icons.chair_rounded, size: 40)),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_cart_rounded, color: AppColors.primary, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white : AppColors.textPrimaryL,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Buy Now',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

