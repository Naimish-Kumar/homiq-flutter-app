import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/layout_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class LayoutDetailScreen extends StatelessWidget {
  final LayoutModel layout;
  const LayoutDetailScreen({super.key, required this.layout});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.textPrimaryL),
          onPressed: () => context.pop(),
        ),
        title: Text(
          layout.name,
          style: GoogleFonts.playfairDisplay(
            color: isDark ? Colors.white : AppColors.textPrimaryL,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, '3D Visualization', Icons.view_in_ar_rounded),
            const SizedBox(height: 16),
            if (layout.isCompleted && layout.result3dUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: layout.result3dUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.black12, child: const Center(child: CircularProgressIndicator())),
                  ),
                ),
              )
            else if (layout.isProcessing)
              _buildEmptyState(
                context,
                Icons.hourglass_empty_rounded,
                'Processing...',
                'Our AI is building your 3D scene. This usually takes a few minutes.',
              )
            else
              _buildEmptyState(
                context,
                Icons.error_outline_rounded,
                'Failed',
                'There was an error processing this layout.',
              ),
            
            const SizedBox(height: 40),
            _buildSectionHeader(context, 'Original Floor Plan', Icons.map_outlined),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CachedNetworkImage(
                imageUrl: layout.floorPlanUrl,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: layout.isCompleted 
          ? Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: PrimaryButton(
                label: 'Open Full 3D Viewer',
                onPressed: () {
                  // In a real app, navigate to a 3D viewer screen or WebView
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Interactive 3D Viewer is being prepared!')),
                  );
                },
                icon: Icons.open_in_new_rounded,
              ),
            )
          : null,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimaryL,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String title, String sub) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(sub, textAlign: TextAlign.center, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
