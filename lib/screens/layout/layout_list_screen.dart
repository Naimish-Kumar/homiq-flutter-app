import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/layout/layout_bloc.dart';
import '../../models/layout_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class LayoutListScreen extends StatefulWidget {
  const LayoutListScreen({super.key});

  @override
  State<LayoutListScreen> createState() => _LayoutListScreenState();
}

class _LayoutListScreenState extends State<LayoutListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LayoutBloc>().add(LoadLayouts());
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
                '3D Layouts',
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
                onPressed: () => context.push('/layouts/upload'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          BlocBuilder<LayoutBloc, LayoutState>(
            builder: (context, state) {
              if (state is LayoutLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (state is LayoutError) {
                return SliverFillRemaining(
                  child: Center(child: Text(state.message)),
                );
              }

              if (state is LayoutLoaded) {
                if (state.layouts.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.view_in_ar_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'No 3D layouts yet',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: isDark ? AppColors.textMuted : AppColors.textMutedL,
                            ),
                          ),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            label: 'Upload Floor Plan',
                            onPressed: () => context.push('/layouts/upload'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final layout = state.layouts[i];
                        return _LayoutCard(layout: layout);
                      },
                      childCount: state.layouts.length,
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

class _LayoutCard extends StatelessWidget {
  final LayoutModel layout;
  const _LayoutCard({required this.layout});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        onTap: () => context.push('/layouts/detail', extra: layout),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(layout.floorPlanUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    layout.name,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimaryL,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(layout.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          layout.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(layout.status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${layout.createdAt.day}/${layout.createdAt.month}/${layout.createdAt.year}',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.textMuted : AppColors.textMutedL,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'processing':
        return AppColors.accent;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }
}
