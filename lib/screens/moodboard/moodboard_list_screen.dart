import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/moodboard/moodboard_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

import '../../models/moodboard_model.dart';

class MoodboardListScreen extends StatefulWidget {
  const MoodboardListScreen({super.key});

  @override
  State<MoodboardListScreen> createState() => _MoodboardListScreenState();
}

class _MoodboardListScreenState extends State<MoodboardListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MoodboardBloc>().add(LoadMoodboards());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : AppColors.textPrimaryL,
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Moodboards',
                style: GoogleFonts.playfairDisplay(
                  color: isDark ? Colors.white : AppColors.textPrimaryL,
                  fontWeight: FontWeight.w800,
                ),
              ),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                onPressed: () => context.push('/moodboards/create'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          BlocBuilder<MoodboardBloc, MoodboardState>(
            builder: (context, state) {
              if (state is MoodboardLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (state is MoodboardError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(state.message),
                        TextButton(
                          onPressed: () => context.read<MoodboardBloc>().add(LoadMoodboards()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is MoodboardLoaded) {
                if (state.moodboards.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.dashboard_customize_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'No moodboards yet',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: isDark ? AppColors.textMuted : AppColors.textMutedL,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first design inspiration',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? AppColors.textMuted : AppColors.textMutedL,
                            ),
                          ),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            label: 'Create New',
                            onPressed: () => context.push('/moodboards/create'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final moodboard = state.moodboards[index];
                        return _MoodboardCard(moodboard: moodboard);
                      },
                      childCount: state.moodboards.length,
                    ),
                  ),
                );
              }

              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }
}

class _MoodboardCard extends StatelessWidget {
  final MoodboardModel moodboard;
  const _MoodboardCard({required this.moodboard});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      onTap: () => context.push('/moodboards/detail', extra: moodboard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: moodboard.items.isEmpty
                  ? Center(
                      child: Icon(
                        Icons.dashboard_rounded,
                        color: AppColors.primary.withValues(alpha: 0.3),
                        size: 32,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Stack(
                        children: [
                          Image.network(
                            moodboard.items.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          if (moodboard.items.length > 1)
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '+${moodboard.items.length - 1}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moodboard.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimaryL,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (moodboard.colorPalette.isNotEmpty)
                  Row(
                    children: moodboard.colorPalette.take(4).map((color) {
                      return Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: Color(int.parse(color.replaceAll('#', '0xFF'))),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
                        ),
                      );
                    }).toList(),
                  )
                else
                  Text(
                    moodboard.style?.name ?? 'No Style',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textMuted : AppColors.textMutedL,
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
