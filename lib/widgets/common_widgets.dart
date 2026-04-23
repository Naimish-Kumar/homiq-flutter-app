// lib/widgets/common_widgets.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ─── PrimaryButton (with scale-on-press + shimmer gradient) ──────────────────

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final dynamic icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: enabled ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: enabled ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: AppDurations.fast,
        curve: AppCurves.defaultCurve,
        child: SizedBox(
          width: widget.fullWidth ? double.infinity : null,
          height: 58,
          child: AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary,
                      AppColors.primaryLight,
                      AppColors.primary,
                      AppColors.primary,
                    ],
                    stops: [
                      0.0,
                      (_shimmerController.value - 0.2).clamp(0.0, 1.0),
                      _shimmerController.value,
                      (_shimmerController.value + 0.2).clamp(0.0, 1.0),
                      1.0,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: enabled ? AppColors.buttonShadow : null,
                ),
                child: child,
              );
            },
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            SmartIcon(
                              widget.icon,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.label,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final dynamic icon;

  const GoldButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: icon,
    );
  }
}

// ─── GlassCard ───────────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final double blur;
  final Border? border;
  final Gradient? gradient;
  final Color? backgroundColor;
  final BoxShape shape;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
    this.blur = 12,
    this.border,
    this.gradient,
    this.backgroundColor,
    this.shape = BoxShape.rectangle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: shape == BoxShape.circle
          ? BorderRadius.circular(999)
          : BorderRadius.circular(borderRadius),
      child: GestureDetector(
        onTap: onTap,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  backgroundColor ??
                  (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.7)),
              borderRadius: shape == BoxShape.circle
                  ? null
                  : BorderRadius.circular(borderRadius),
              shape: shape,
              gradient: gradient,
              border:
                  border ??
                  Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.06),
                    width: 1,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── ShimmerLoader ───────────────────────────────────────────────────────────

class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoader({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 16,
  });

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.shimmer,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.surface : AppColors.surfaceVariantL;
    final highlightColor = isDark
        ? AppColors.surfaceLight
        : AppColors.backgroundLight;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
              begin: const Alignment(-1, 0),
              end: const Alignment(2, 0),
            ),
          ),
        );
      },
    );
  }
}

// ─── AnimatedListItem (staggered entrance) ───────────────────────────────────

class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Animation<double> animation;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
              ),
            ),
        child: child,
      ),
    );
  }
}

// ─── FeatureBadge ────────────────────────────────────────────────────────────

class FeatureBadge extends StatelessWidget {
  final String label;
  final Color color;
  final dynamic icon;

  const FeatureBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SmartIcon(icon, size: 12, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.overline.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AnimatedCounter ─────────────────────────────────────────────────────────

class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Text(
          '$val',
          style:
              style ??
              AppTextStyles.headlineLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
        );
      },
    );
  }
}

// ─── HomiqTextField ──────────────────────────────────────────────────────────

class HomiqTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const HomiqTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<HomiqTextField> createState() => _HomiqTextFieldState();
}

class _HomiqTextFieldState extends State<HomiqTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            widget.label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _isFocused
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryL),
              letterSpacing: 0.2,
            ),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.isPassword,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          cursorColor: AppColors.primary,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryL,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textMuted : AppColors.textMutedL,
              fontSize: 14,
            ),

            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: 20,
                    color: _isFocused
                        ? AppColors.primary
                        : (isDark ? AppColors.textMuted : AppColors.textMutedL),
                  )
                : null,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.textMuted : AppColors.textMutedL,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.textMuted : AppColors.textMutedL,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── SectionHeader ───────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryL,
            letterSpacing: -0.5,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textMuted : AppColors.textMutedL,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Dividers ────────────────────────────────────────────────────────────────

class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key});
  @override
  Widget build(BuildContext context) => const HomiqDivider();
}

class HomiqDivider extends StatelessWidget {
  const HomiqDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.border
                    : AppColors.borderL)
                .withValues(alpha: 0.5),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─── DesignChip ──────────────────────────────────────────────────────────────

class DesignChip extends StatelessWidget {
  final String label;
  final dynamic icon;
  final bool isSelected;
  final VoidCallback onTap;

  const DesignChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isDark ? AppColors.surfaceLight : AppColors.surfaceVariantL),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.border : AppColors.borderL),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SmartIcon(
              icon,
              size: 14,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryL),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryL),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── LoadingOverlay ──────────────────────────────────────────────────────────

class LoadingOverlay extends StatelessWidget {
  final String message;
  const LoadingOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primary, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                  strokeWidth: 2.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(message, style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text(
              'This may take up to 30 seconds',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── BudgetCard ──────────────────────────────────────────────────────────────

class BudgetCard extends StatelessWidget {
  final String label;
  final String description;
  final String priceRange;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const BudgetCard({
    super.key,
    required this.label,
    required this.description,
    required this.priceRange,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.medium,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.1)
              : isDark
              ? AppColors.surface
              : AppColors.surfaceL,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? color
                : isDark
                ? AppColors.border
                : AppColors.borderL,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? color
                    : isDark
                    ? AppColors.surface
                    : AppColors.surfaceVariantL,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected
                    ? Colors.white
                    : isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryL,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: selected
                          ? color
                          : isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryL,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceRange,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: selected
                        ? color
                        : isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryL,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: color, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DesignHistoryCard ───────────────────────────────────────────────────────

class DesignHistoryCard extends StatelessWidget {
  final String roomName;
  final IconData styleIcon;
  final String styleLabel;
  final IconData budgetIcon;
  final String budgetLabel;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const DesignHistoryCard({
    super.key,
    required this.roomName,
    required this.styleIcon,
    required this.styleLabel,
    required this.budgetIcon,
    required this.budgetLabel,
    this.imageUrl,
    required this.createdAt,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: GlassDecoration.elevated(isDark: isDark, borderRadius: 20),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            color: isDark
                                ? AppColors.surface
                                : AppColors.surfaceVariantL,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        )
                      : Container(
                          color: isDark
                              ? AppColors.surface
                              : AppColors.surfaceVariantL,
                        ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          roomName,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(styleIcon, size: 12, color: AppColors.accent),
                            const SizedBox(width: 8),
                            Text(styleLabel, style: AppTextStyles.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              budgetIcon,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(budgetLabel, style: AppTextStyles.bodyMedium),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(createdAt),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onFavorite,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.red : Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

// ─── LogoutDialog ────────────────────────────────────────────────────────────

class LogoutDialog extends StatelessWidget {
  final VoidCallback onLogout;
  const LogoutDialog({super.key, required this.onLogout});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onLogout,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => LogoutDialog(onLogout: onLogout),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: GlassDecoration.elevated(isDark: isDark, borderRadius: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppTheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text('Sign Out?', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to log out of your Homiq account?',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryL,
              ),
            ),
            const SizedBox(height: 32),
            GoldButton(
              label: 'Sign Out',
              onPressed: () {
                Navigator.pop(context);
                onLogout();
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isDark ? AppColors.textMuted : AppColors.textMutedL,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SmartIcon ───────────────────────────────────────────────────────────────

class SmartIcon extends StatelessWidget {
  final dynamic icon;
  final double? size;
  final Color? color;

  const SmartIcon(this.icon, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    if (icon == null) return const SizedBox.shrink();
    if (icon is FaIconData)
      return FaIcon(icon as FaIconData, size: size, color: color);
    if (icon is IconData)
      return Icon(icon as IconData, size: size, color: color);
    return const SizedBox.shrink();
  }
}

// ─── MeshGradient ────────────────────────────────────────────────────────────

class MeshGradient extends StatefulWidget {
  const MeshGradient({super.key});

  @override
  State<MeshGradient> createState() => _MeshGradientState();
}

class _MeshGradientState extends State<MeshGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: MeshGradientPainter(
          progress: _controller.value,
          isDark: isDark,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class MeshGradientPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  MeshGradientPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final blobs = [
      MeshBlob(
        color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
        center: Offset(
          size.width * (0.3 + 0.15 * sin(progress * 2 * pi)),
          size.height * (0.2 + 0.1 * cos(progress * 2 * pi)),
        ),
        radius: size.width * 0.45,
      ),
      MeshBlob(
        color: AppColors.badgePurple.withValues(alpha: isDark ? 0.1 : 0.04),
        center: Offset(
          size.width * (0.7 + 0.12 * cos(progress * 2 * pi + 1)),
          size.height * (0.6 + 0.15 * sin(progress * 2 * pi + 1)),
        ),
        radius: size.width * 0.5,
      ),
      MeshBlob(
        color: AppColors.accent.withValues(alpha: isDark ? 0.08 : 0.04),
        center: Offset(
          size.width * (0.5 + 0.2 * sin(progress * 2 * pi + 2)),
          size.height * (0.8 + 0.1 * cos(progress * 2 * pi + 2)),
        ),
        radius: size.width * 0.4,
      ),
    ];

    for (final blob in blobs) {
      final paint = Paint()
        ..shader =
            RadialGradient(
              colors: [blob.color, blob.color.withValues(alpha: 0)],
            ).createShader(
              Rect.fromCircle(center: blob.center, radius: blob.radius),
            );
      canvas.drawCircle(blob.center, blob.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MeshGradientPainter old) =>
      old.progress != progress;
}

class MeshBlob {
  final Color color;
  final Offset center;
  final double radius;
  MeshBlob({required this.color, required this.center, required this.radius});
}
