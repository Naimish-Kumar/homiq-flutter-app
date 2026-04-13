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
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;
  late Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _entranceController.forward();
    _refreshData();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    context.read<FetchStylesCubit>().fetchStyles();
    context.read<FetchMyDesignsCubit>().fetchMyDesigns();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        body: Stack(
          children: [
            // Luxury Mesh Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: context.color.brightness == Brightness.light
                      ? [
                          const Color(0xFFFBFBF9),
                          const Color(0xFFF5F5F4),
                          context.color.tertiaryColor.withValues(alpha: 0.1),
                          const Color(0xFFFBFBF9),
                        ]
                      : [
                          const Color(0xFF0C0A09),
                          const Color(0xFF1C1917),
                          context.color.tertiaryColor.withValues(alpha: 0.15),
                          const Color(0xFF0C0A09),
                        ],
                  stops: const [0.0, 0.4, 0.8, 1.0],
                ),
              ),
            ),
            // Floating Mesh Glow
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.color.tertiaryColor.withValues(alpha: 0.05),
                ),
              ),
            ),
            CustomRefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SlideTransition(
                      position: _headerSlide,
                      child: FadeTransition(
                        opacity: _headerOpacity,
                        child: _buildHeader(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _contentOpacity,
                      child: Column(
                        children: [
                          _buildStudioGateway(),
                          const SizedBox(height: 48),
                          _buildStylesSection(),
                          const SizedBox(height: 48),
                          _buildRecentActivity(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = HiveUtils.getUserDetails();
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.color.tertiaryColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: context.color.brightness == Brightness.light
                  ? Colors.black.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.1),
              backgroundImage: user.profile != '' ? NetworkImage(user.profile!) : null,
              child: user.profile == ''
                  ? FaIcon(AppIcons.profile,
                      color: context.color.tertiaryColor, size: 24)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  'COLLECTION OF',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: context.color.textLightColor,
                  letterSpacing: 2,
                ),
                const SizedBox(height: 2),
                CustomText(
                  user.name?.toUpperCase() ?? 'DESIGNER',
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: context.color.textColorDark,
                  letterSpacing: 2,
                  useSerif: true,
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
            color: context.color.tertiaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.color.tertiaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              const FaIcon(FontAwesomeIcons.bolt,
                  color: Colors.amber, size: 14),
              const SizedBox(width: 8),
              CustomText(
                '12',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: context.color.textColorDark,
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
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: context.color.tertiaryColor.withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: -10,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Stack(
              children: [
                // Luxury Mesh Header Background
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.color.tertiaryColor,
                          const Color(0xFF1C1917),
                        ],
                      ),
                    ),
                  ),
                ),
                // Sublte Mesh Glow
                Positioned(
                  right: -50,
                  top: -50,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const FaIcon(AppIcons.magic,
                            color: Colors.white, size: 24),
                      ),
                      const Spacer(),
                      CustomText(
                        'AI DESIGN STUDIO',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 3,
                      ),
                      const SizedBox(height: 8),
                      const CustomText(
                        'Transform Your Space',
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        useSerif: true,
                      ),
                      const SizedBox(height: 6),
                      CustomText(
                        'Upload room & visualize styles instantly',
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),

                // Premium Action Trigger
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CustomText(
                          'START',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: context.color.tertiaryColor,
                          letterSpacing: 1,
                        ),
                        const SizedBox(width: 8),
                        FaIcon(
                          AppIcons.forward,
                          color: context.color.tertiaryColor,
                          size: 14,
                        ),
                      ],
                    ),
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
      width: 150,
      margin: const EdgeInsets.only(right: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                color: context.color.secondaryColor,
                border: Border.all(
                  color: context.color.tertiaryColor.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: CustomImage(
                  imageUrl: imageUrl ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomText(
              name.toUpperCase(),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: context.color.textColorDark,
              letterSpacing: 2,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
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
      color: context.color.textColorDark,
      letterSpacing: 1.5,
    );
  }

  Widget _buildEmptyActivity() {
    return Center(
      child: Column(
        children: [
          FaIcon(FontAwesomeIcons.wandMagic,
              size: 40, color: context.color.textLightColor.withOpacity(0.3)),
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomImage(
                  imageUrl: design['result_image_url'] as String,
                  fit: BoxFit.cover,
                ),
              ),
              // Luxury Inset Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.4, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      (design['style']?['name'] as String?)?.toUpperCase() ??
                          'CONCEPT',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: context.color.tertiaryColor,
                      letterSpacing: 2,
                    ),
                    const SizedBox(height: 4),
                    const CustomText(
                      'Collection Details',
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
