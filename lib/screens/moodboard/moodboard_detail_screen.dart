import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/moodboard/moodboard_bloc.dart';
import '../../models/moodboard_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class MoodboardDetailScreen extends StatelessWidget {
  final MoodboardModel moodboard;
  const MoodboardDetailScreen({super.key, required this.moodboard});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(moodboard.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push('/moodboards/edit', extra: moodboard),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (moodboard.description != null && moodboard.description!.isNotEmpty) ...[
              Text(
                moodboard.description!,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryL,
                ),
              ),
              const SizedBox(height: 32),
            ],
            
            Text('COLOR PALETTE', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            if (moodboard.colorPalette.isEmpty)
              Text('No colors selected', style: TextStyle(color: AppColors.textMuted, fontSize: 12))
            else
              Row(
                children: moodboard.colorPalette.map((hex) {
                  final color = Color(int.parse(hex.replaceAll('#', '0xFF')));
                  return Expanded(
                    child: Container(
                      height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          hex,
                          style: TextStyle(
                            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 32),
            Text('ASSOCIATED STYLE', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.palette_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moodboard.style?.name ?? 'No Style Selected',
                          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Design inspiration style',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Text('ITEMS & INSPIRATION', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            if (moodboard.items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text('No items added yet', style: TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: moodboard.items.length,
                itemBuilder: (context, i) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(moodboard.items[i], fit: BoxFit.cover),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Moodboard'),
        content: const Text('Are you sure you want to delete this moodboard? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<MoodboardBloc>().add(DeleteMoodboard(moodboard.id));
              Navigator.pop(dialogContext);
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
