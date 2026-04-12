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
      appBar: CustomAppBar(
        backgroundColor: context.color.primaryColor,
        title: CustomText(
          'Galleria',
          fontWeight: FontWeight.bold,
          color: context.color.textColorDark,
          fontSize: context.font.lg,
          letterSpacing: 1.2,
        ),
        showBackButton: false,
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
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Color(0xFF49A9B4)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.color.tertiaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.collections_bookmark_rounded,
                size: 64, color: context.color.tertiaryColor.withOpacity(0.4)),
          ),
          const SizedBox(height: 24),
          const CustomText('No Masterpieces Yet',
              fontSize: 20, fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          CustomText('Transform your first room in the studio',
              color: context.color.textLightColor),
          const SizedBox(height: 32),
          UiUtils.buildButton(
            context,
            onPressed: () => Navigator.pushNamed(context, Routes.designStudio),
            buttonTitle: 'ENTER STUDIO',
            width: 200,
            buttonColor: context.color.tertiaryColor,
          ),
        ],
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomImage(
                    imageUrl: design['result_image_url'] as String,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          color: Colors.black26,
                          child: const CustomText(
                            'CONCEPT',
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  (design['style']?['name'] as String?)?.toUpperCase() ??
                      'AI DESIGN',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: context.color.tertiaryColor,
                  letterSpacing: 1,
                ),
                const SizedBox(height: 4),
                CustomText(
                  timeago.format(
                      DateTime.tryParse(design['created_at'].toString()) ??
                          DateTime.now()),
                  fontSize: 12,
                  color: context.color.textLightColor,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
