import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/ui/screens/home/widgets/custom_refresh_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.from});
  final String? from;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    context.read<FetchStylesCubit>().fetchStyles();
    context.read<FetchMyDesignsCubit>().fetchMyDesigns();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      body: CustomRefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildStudioGateway(),
              const SizedBox(height: 40),
              _buildStylesSection(),
              const SizedBox(height: 40),
              _buildRecentActivity(),
              const SizedBox(height: 120), // Space for bottom bar/FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = HiveUtils.getUserDetails();
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.color.tertiaryColor.withOpacity(0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.color.tertiaryColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: context.color.tertiaryColor.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: context.color.secondaryColor,
              backgroundImage: user.profile != '' ? NetworkImage(user.profile!) : null,
              child: user.profile == ''
                  ? Icon(Icons.person_rounded, color: context.color.tertiaryColor, size: 32)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  'Good Morning,',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.color.textLightColor,
                  letterSpacing: 0.5,
                ),
                CustomText(
                  user.name?.toUpperCase() ?? 'DESIGNER',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: context.color.textColorDark,
                  letterSpacing: 1.2,
                ),
              ],
            ),
          ),
          _buildCreditsIndicator(),
        ],
      ),
    );
  }

  Widget _buildCreditsIndicator() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.color.tertiaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.color.tertiaryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              const CustomText(
                '12',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              CustomText(
                'PASSES',
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: context.color.tertiaryColor,
                letterSpacing: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudioGateway() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, Routes.designStudio),
        child: Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: context.color.tertiaryColor.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Background Glow/Pattern
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.color.tertiaryColor,
                          context.color.secondaryColor,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -50,
                  top: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.auto_fix_high_rounded,
                            color: Colors.white, size: 32),
                      ),
                      const Spacer(),
                      const CustomText(
                        'START TRANSFORMATION',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                      const SizedBox(height: 8),
                      const CustomText(
                        'AI Interior Studio',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      CustomText(
                        'Upload room & visualize styles instantly',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),

                // Action Indicator
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        color: context.color.tertiaryColor, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStylesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader('CURATED STYLES'),
              GestureDetector(
                onTap: () {},
                child: CustomText(
                  'VIEW ALL',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: context.color.tertiaryColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        BlocBuilder<FetchStylesCubit, FetchStylesState>(
          builder: (context, state) {
            if (state is FetchStylesInProgress) {
              return SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 4,
                  itemBuilder: (_, __) => _buildStyleShimmer(),
                ),
              );
            }
            if (state is FetchStylesSuccess) {
              return SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.styles.length,
                  itemBuilder: (context, index) {
                    final style = state.styles[index];
                    return _styleCard(
                      style['name'] as String,
                      style['preview_image'] as String?,
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _styleCard(String name, String? imageUrl) {
    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
                image: imageUrl != null && imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: context.color.secondaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          CustomText(
            name.toUpperCase(),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: context.color.textColorDark,
            letterSpacing: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStyleShimmer() {
    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _sectionHeader('RECENT COLLECTIONS'),
        ),
        const SizedBox(height: 20),
        BlocBuilder<FetchMyDesignsCubit, FetchMyDesignsState>(
          builder: (context, state) {
            if (state is FetchMyDesignsInProgress) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FetchMyDesignsSuccess) {
              if (state.designs.isEmpty) {
                return _buildEmptyActivity();
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: state.designs.take(4).length,
                itemBuilder: (context, index) {
                  final design = state.designs[index];
                  return _designCard(design);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return CustomText(
      title,
      fontSize: 13,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      letterSpacing: 1.5,
    );
  }

  Widget _buildEmptyActivity() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.auto_fix_off_rounded,
              size: 48, color: context.color.textLightColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          CustomText(
            'NO TRANSFORMATIONS YET',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: context.color.textLightColor,
            letterSpacing: 1,
          ),
        ],
      ),
    );
  }

  Widget _designCard(dynamic design) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.designResult,
          arguments: {'result': design, 'original': null},
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomImage(
                imageUrl: design['result_image_url'] as String,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    (design['style']?['name'] as String?)?.toUpperCase() ??
                        'CONCEPT',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: context.color.tertiaryColor,
                  ),
                  const SizedBox(height: 2),
                  const CustomText(
                    'View Details',
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
