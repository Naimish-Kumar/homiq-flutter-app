import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:homiq/data/cubits/design/fetch_my_designs_cubit.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/ui/screens/home/widgets/custom_refresh_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    context.read<FetchMyDesignsCubit>().fetchMyDesigns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: CustomText(
          'GALLERIA',
          fontWeight: FontWeight.w900,
          color: context.color.textColorDark,
          fontSize: 14,
          letterSpacing: 4,
        ),
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async => _fetch(),
        child: BlocBuilder<FetchMyDesignsCubit, FetchMyDesignsState>(
          builder: (context, state) {
            if (state is FetchMyDesignsInProgress) {
              return _buildLoadingState();
            }

            if (state is FetchMyDesignsFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    CustomText(state.errorMessage, color: Colors.red),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: _fetch,
                      child: const CustomText('Retry',
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }

            if (state is FetchMyDesignsSuccess) {
              if (state.designs.isEmpty) {
                return _buildEmptyState();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: CustomText(
                      'Your past design explorations',
                      color: context.color.textLightColor,
                      fontSize: context.font.sm,
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: state.designs.length,
                      itemBuilder: (context, index) {
                        return _buildDesignCard(state.designs[index]);
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: UiUtils.progress(
        normalProgressColor: context.color.tertiaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: context.color.tertiaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  size: 60, color: context.color.tertiaryColor),
            ),
            const SizedBox(height: 40),
            const CustomText(
              'CURATE YOUR COLLECTION',
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomText(
              'Your Al-crafted transformations will appear here as you explore new aesthetics.',
              color: context.color.textLightColor,
              textAlign: TextAlign.center,
              
            ),
            const SizedBox(height: 48),
            Container(
              width: 220,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: context.color.tertiaryColor.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.designStudio),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.color.tertiaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const CustomText(
                  'ENTER STUDIO',
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignCard(dynamic design) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.designResult,
          arguments: {'result': design, 'original': null},
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomImage(
                      imageUrl: design['result_image_url'] as String,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            color: Colors.black.withValues(alpha: 0.3),
                            child: const CustomText(
                              'CONCEPT',
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  (design['style']?['name'] as String?)?.toUpperCase() ??
                      'AI DESIGN',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: context.color.tertiaryColor,
                  letterSpacing: 1.5,
                ),
                const SizedBox(height: 6),
                CustomText(
                  timeago
                      .format(
                          DateTime.tryParse(design['created_at'].toString()) ??
                              DateTime.now())
                      .toUpperCase(),
                  fontSize: 10,
                  color: context.color.textLightColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
