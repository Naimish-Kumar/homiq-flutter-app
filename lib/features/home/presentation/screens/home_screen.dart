import 'dart:developer';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/features/home/presentation/screens/widgets/custom_refresh_indicator.dart';
import 'package:homiq/features/studio/data/models/room_design_model.dart';
import 'package:homiq/features/studio/domain/entities/design_style.dart';
import 'package:homiq/features/studio/presentation/screens/studio_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.from});
  final String? from;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
            // Modern Animated Mesh Gradient Background
            Container(
              decoration: BoxDecoration(gradient: context.color.meshGradient),
            ),
            // Floating Decorative Glows
            Positioned(
              top: -150,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.color.tertiaryColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -150,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.color.accentColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            CustomRefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
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
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        20,
      ),
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
              backgroundImage: user.profile != ''
                  ? NetworkImage(user.profile!)
                  : null,
              child: user.profile == ''
                  ? FaIcon(
                      AppIcons.profile,
                      color: context.color.tertiaryColor,
                      size: 24,
                    )
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
              const FaIcon(
                FontAwesomeIcons.bolt,
                color: Colors.amber,
                size: 14,
              ),
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
        onTap: () =>
            Navigator.push(context, StudioScreen.route(const RouteSettings())),
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
                // Premium Rose Gold Metallic Gradient Background
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
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
                // Modern Decorative Mesh Overlay
                Positioned(
                  right: -70,
                  top: -70,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Content Area with Glass Card
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: const FaIcon(
                              AppIcons.magic,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      CustomText(
                        'AI DESIGN STUDIO',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 4,
                      ),
                      const SizedBox(height: 8),
                      const CustomText(
                        'Reimagine Space',
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        useSerif: true,
                        letterSpacing: -0.5,
                      ),
                      const SizedBox(height: 6),
                      CustomText(
                        'Upload architecture & visualize styles instantly.',
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),

                // Premium Glass Action Trigger
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CustomText(
                              'START',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: context.color.blackColor,
                              letterSpacing: 2,
                            ),
                            const SizedBox(width: 10),
                            FaIcon(
                              AppIcons.forward,
                              color: context.color.blackColor,
                              size: 16,
                            ),
                          ],
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
                    final style = state.styles[index] as DesignStyle;
                    log(style.imageUrl.toString());
                    return _styleCard(style.name, style.imageUrl);
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
    log(imageUrl.toString());
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 24, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: context.color.secondaryColor,
                border: Border.all(
                  color: context.color.tertiaryColor.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.color.tertiaryColor.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomImage(imageUrl: imageUrl, fit: BoxFit.cover),
                    ),
                    // Light Glint Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.1),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.1),
                            ],
                            stops: const [0.0, 0.5, 1.0],
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomText(
              name.toUpperCase(),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: context.color.textColorDark,
              letterSpacing: 3,
              textAlign: TextAlign.start,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleShimmer() {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: context.color.shimmerBaseColor,
        borderRadius: BorderRadius.circular(40),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader('COLLECTIONS'),
              const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 12,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
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
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.75,
                ),
                itemCount: state.designs.take(4).length,
                itemBuilder: (context, index) {
                  final design = state.designs[index] as RoomDesignModel;
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
      fontSize: 12,
      fontWeight: FontWeight.w900,
      color: context.color.textColorDark,
      letterSpacing: 2,
    );
  }

  Widget _buildEmptyActivity() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.color.tertiaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                FontAwesomeIcons.wandMagicSparkles,
                size: 32,
                color: context.color.tertiaryColor.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            CustomText(
              'AWAITING YOUR CREATIVE VISION',
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: context.color.textLightColor,
              letterSpacing: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _designCard(RoomDesignModel design) {
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: context.color.tertiaryColor.withValues(alpha: 0.15),
              blurRadius: 25,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomImage(
                  imageUrl: design.generatedImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              // Modern Gradient Scrim
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.9),
                      ],
                      stops: const [0.5, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.color.tertiaryColor.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: context.color.tertiaryColor.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: CustomText(
                        design.style?.name.toUpperCase() ?? 'CONCEPT',
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: context.color.tertiaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const CustomText(
                      'Luxury Space',
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      useSerif: true,
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
