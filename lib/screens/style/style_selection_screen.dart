// lib/screens/style/style_selection_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/design/design_bloc.dart';
import '../../models/design_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class StyleSelectionScreen extends StatefulWidget {
  final File image;
  final String roomType;
  const StyleSelectionScreen({
    super.key,
    required this.image,
    required this.roomType,
  });

  @override
  State<StyleSelectionScreen> createState() => _StyleSelectionScreenState();
}

class _StyleSelectionScreenState extends State<StyleSelectionScreen>
    with SingleTickerProviderStateMixin {
  dynamic _selectedStyle; // DesignStyle or StyleModel
  BudgetLevel? _selectedBudget;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.2, 1.0, curve: AppCurves.defaultCurve),
          ),
        );
    _animController.forward();
    context.read<DesignBloc>().add(DesignLoadStyles());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _generate() {
    if (_selectedStyle == null || _selectedBudget == null) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    if (!authState.user.isPremium && authState.user.freeDesignsLeft <= 0) {
      context.push('/pricing');
      return;
    }

    context.read<DesignBloc>().add(
      DesignGenerate(
        image: widget.image,
        style: _selectedStyle!,
        budget: _selectedBudget!,
        roomType: widget.roomType,
        userId: authState.user.id,
      ),
    );

    context.push('/loading');
  }

  bool get _canProceed => _selectedStyle != null && _selectedBudget != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : AppColors.textPrimaryL,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Customize Design',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: isDark ? Colors.white : AppColors.textPrimaryL,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ── Mesh Background
          const MeshGradient(),

          // ── Main Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              'Choose your style &\nbudget',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimaryL,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AI will redesign your room accordingly',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: isDark
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Thumbnail preview
                            Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.file(
                                  widget.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Style section
                            const SectionHeader(
                              title: 'Design Style',
                              subtitle: 'Select your preferred aesthetic',
                            ),
                            const SizedBox(height: 16),

                            BlocBuilder<DesignBloc, DesignState>(
                              builder: (context, state) {
                                if (state is DesignStylesLoading) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(40),
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                }

                                List<dynamic> styles = DesignStyle.values;
                                if (state is DesignStylesLoaded) {
                                  styles = state.styles;
                                }

                                return Column(
                                  children: styles
                                      .map(
                                        (style) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: _StyleCard(
                                            style: style,
                                            isSelected: _selectedStyle == style,
                                            onTap: () => setState(
                                              () => _selectedStyle = style,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // Budget section
                            const SectionHeader(
                              title: 'Budget Range',
                              subtitle: 'Furniture suggested per your range',
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: BudgetLevel.values.map((budget) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _BudgetCard(
                                      budget: budget,
                                      isSelected: _selectedBudget == budget,
                                      onTap: () => setState(
                                        () => _selectedBudget = budget,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: PrimaryButton(
                    label: 'Generate Design',
                    icon: FontAwesomeIcons.wandMagicSparkles,
                    onPressed: _canProceed ? _generate : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleCard extends StatelessWidget {
  final dynamic style; // DesignStyle or StyleModel
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleCard({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  static const _descriptions = {
    DesignStyle.modern: 'Clean lines, neutral tones',
    DesignStyle.minimal: 'Functional simplicity',
    DesignStyle.luxury: 'Opulent & elegant',
    DesignStyle.traditionalIndian: 'Heritage & classic motifs',
    DesignStyle.scandinavian: 'Cozy & light wood',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconData = style is DesignStyle
        ? (style as DesignStyle).icon
        : (style as StyleModel).enumStyle.icon;

    final label = style is DesignStyle
        ? (style as DesignStyle).label
        : (style as StyleModel).name;

    final description = style is DesignStyle
        ? (_descriptions[style] ?? '')
        : (style as StyleModel).promptPrefix ?? 'Custom AI style';

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const .all(16),
        border: isSelected
            ? .all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5)
            : null,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppColors.heroGradient
                    : LinearGradient(
                        colors: [
                          isDark
                              ? Colors.white10
                              : Colors.black.withValues(alpha: 0.05),
                          isDark
                              ? Colors.white10
                              : Colors.black.withValues(alpha: 0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SmartIcon(
                  iconData,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryL),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? Colors.white : AppColors.textPrimaryL),
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.textMuted
                          : AppColors.textMutedL,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 24,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: isDark ? Colors.white24 : Colors.black12,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetLevel budget;
  final bool isSelected;
  final VoidCallback onTap;

  const _BudgetCard({
    required this.budget,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        border: isSelected
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
        child: Column(
          children: [
            SmartIcon(
              budget.icon,
              size: 24,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryL),
            ),
            const SizedBox(height: 10),
            Text(
              budget.label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white : AppColors.textPrimaryL),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              budget.range,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: isDark ? AppColors.textMuted : AppColors.textMutedL,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
