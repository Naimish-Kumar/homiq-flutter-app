import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/features/home/presentation/screens/widgets/custom_refresh_indicator.dart';
import 'package:homiq/features/studio/data/models/room_design_model.dart';
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
      body: Stack(
        children: [
          // Modern Animated Rose Gold Mesh Background
          Container(
            decoration: BoxDecoration(gradient: context.color.meshGradient),
          ),
          // Floating Decorative Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.color.tertiaryColor.withValues(alpha: 0.1),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: CustomRefreshIndicator(
                    onRefresh: () async => _fetch(),
                    child: BlocBuilder<FetchMyDesignsCubit, FetchMyDesignsState>(
                      builder: (context, state) {
                        if (state is FetchMyDesignsInProgress) {
                          return _buildLoadingState();
                        }

                        if (state is FetchMyDesignsFailure) {
                          return _buildErrorState(state.errorMessage);
                        }

                        if (state is FetchMyDesignsSuccess) {
                          if (state.designs.isEmpty) {
                            return _buildEmptyState();
                          }

                          return GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 32,
                                  childAspectRatio: 0.7,
                                ),
                            itemCount: state.designs.length,
                            itemBuilder: (context, index) {
                              return _buildDesignCard(state.designs[index]);
                            },
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.color.textColorDark,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          CustomText(
            'GALLERIA',
            fontWeight: FontWeight.w400,
            color: context.color.textColorDark,
            fontSize: 16,
            letterSpacing: 8,
            useSerif: true,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          CustomText(message, color: Colors.red),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _fetch,
            child: const CustomText('Retry', fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center();
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
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 60,
                color: context.color.tertiaryColor,
              ),
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.color.tertiaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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

  Widget _buildDesignCard(RoomDesignModel design) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ResultScreen(
              originalImage: design.originalImageUrl,
              resultImageUrl: design.generatedImageUrl,
              styleName: design.style?.name ?? 'AI Design',
            ),
          ),
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
                      imageUrl: design.generatedImageUrl,
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
                              horizontal: 12,
                              vertical: 8,
                            ),
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
                  design.style?.name.toUpperCase() ?? 'AI DESIGN',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: context.color.tertiaryColor,
                  letterSpacing: 1.5,
                ),
                const SizedBox(height: 6),
                CustomText(
                  timeago
                      .format(design.createdAt)
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
