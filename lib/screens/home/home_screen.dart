// lib/screens/home/home_screen.dart
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homiq_ai/l10n/app_localizations.dart';
import '../../bloc/theme/theme_cubit.dart';
import '../../bloc/language/language_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/design/design_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _showSavedOnly = false;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<DesignBloc>().add(
        DesignLoadHistory(userId: authState.user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeFeed(
            onTabChange: (i, {bool savedOnly = false}) => setState(() {
              _currentIndex = i;
              _showSavedOnly = savedOnly;
            }),
          ),
          HistoryTab(showSavedOnly: _showSavedOnly),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() {
          _currentIndex = i;
          _showSavedOnly = false; // Reset filter when switching tabs
          // Update URL without pushing new page if possible, 
          // or just stay on /home state-wise.
        }),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 34),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surface.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.grid_view_rounded,
                    activeIcon: Icons.grid_view_rounded,
                    label: 'Discover',
                    isActive: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    icon: Icons.auto_awesome_mosaic_rounded,
                    activeIcon: Icons.auto_awesome_mosaic_rounded,
                    label: 'History',
                    isActive: currentIndex == 1,
                    onTap: () {
                      onTap(1);
                    },
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                    isActive: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? AppColors.primary
                  : (isDark ? Colors.white38 : Colors.black38),
              size: 24,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 8 : 0,
              height: 0,
            ),
            if (isActive)
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Feed ───────────────────────────────────────────────────────────────
class _HomeFeed extends StatelessWidget {
  final Function(int, {bool savedOnly}) onTabChange;
  const _HomeFeed({required this.onTabChange});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userName = authState is AuthAuthenticated
            ? authState.user.name.split(' ').first
            : 'Designer';
        final freeLeft = authState is AuthAuthenticated
            ? authState.user.freeDesignsLeft
            : 0;
        return RefreshIndicator(
          onRefresh: () async {
            context.read<AuthBloc>().add(AuthRefreshRequested());
            if (authState is AuthAuthenticated) {
              context.read<DesignBloc>().add(
                DesignLoadHistory(userId: authState.user.id),
              );
            }
            await Future.delayed(const Duration(milliseconds: 800));
          },
          color: AppColors.primary,
          backgroundColor: Theme.of(context).cardColor,
          edgeOffset: 100,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _HomeHeader(
                  userName: userName,
                  photoUrl: authState is AuthAuthenticated
                      ? authState.user.photoUrl
                      : null,
                ),
              ),
              if (freeLeft > 0)
                SliverToBoxAdapter(
                  child: _FreeDesignsBanner(remaining: freeLeft),
                ),
              SliverToBoxAdapter(
                child: _QuickActions(onTabChange: onTabChange),
              ),
              const SliverToBoxAdapter(child: _StyleShowcase()),
              SliverToBoxAdapter(child: _RecentDesigns(onTabChange: onTabChange)),
              const SliverToBoxAdapter(child: _FeaturesGrid()),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String userName;
  final String? photoUrl;
  const _HomeHeader({required this.userName, this.photoUrl});
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        // Mesh background
        SizedBox(
          height: 280,
          width: double.infinity,
          child: const MeshGradient(),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
              child: Row(
                children: [
                  // Avatar with premium glow
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        image: photoUrl != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(photoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: photoUrl == null
                          ? Center(
                              child: Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : 'U',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          userName,
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryL,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification Button
                  GestureDetector(
                    onTap: () => context.push('/notifications'),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 24,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryL,
                          ),
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Hero card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => context.push('/upload'),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/hero.png',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.8),
                                Colors.black.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'AI POWERED',
                                  style: AppTextStyles.overline.copyWith(
                                    color: AppColors.backgroundLight,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'AI Interior\nDesigner',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 28,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Start Designing',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.auto_awesome,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Quick action buttons row
class _QuickActions extends StatelessWidget {
  final Function(int, {bool savedOnly}) onTabChange;
  const _QuickActions({required this.onTabChange});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK ACTIONS',
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark ? AppColors.textMuted : AppColors.textMutedL,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ActionChip(
                icon: Icons.auto_awesome_rounded,
                label: 'Generate',
                gradient: AppColors.primaryGradient,
                isDark: isDark,
                onTap: () => context.push('/upload'),
              ),
              const SizedBox(width: 12),
              _ActionChip(
                icon: Icons.history_rounded,
                label: 'History',
                gradient: LinearGradient(
                  colors: [
                    AppColors.badgePurple,
                    AppColors.badgePurple.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                isDark: isDark,
                onTap: () => onTabChange(1),
              ),
              const SizedBox(width: 12),
              _ActionChip(
                icon: Icons.favorite_rounded,
                label: 'Saved',
                gradient: LinearGradient(
                  colors: [
                    AppColors.badgePink,
                    AppColors.badgePink.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                isDark: isDark,
                onTap: () => onTabChange(1, savedOnly: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final bool isDark;
  final VoidCallback onTap;
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.isDark,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: 24,
        backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 22, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryL,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreeDesignsBanner extends StatelessWidget {
  final int remaining;
  const _FreeDesignsBanner({required this.remaining});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withValues(alpha: isDark ? 0.12 : 0.08),
              AppColors.badgeAmber.withValues(alpha: isDark ? 0.08 : 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.gift,
                  size: 16,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$remaining free design${remaining != 1 ? 's' : ''} left',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryL,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Upgrade for unlimited',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.textMuted
                          : AppColors.textMutedL,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Upgrade',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleShowcase extends StatelessWidget {
  const _StyleShowcase();
  static const _styles = [
    ('Modern', 'assets/styles/modern.png', AppColors.primary),
    ('Minimal', 'assets/styles/minimal.png', AppColors.badgeBlue),
    ('Luxury', 'assets/styles/luxury.png', AppColors.badgePurple),
    ('Indian', 'assets/styles/indian.png', AppColors.accent),
    ('Nordic', 'assets/styles/nordic.png', AppColors.badgeGreen),
  ];
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DESIGN STYLES',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark ? AppColors.textMuted : AppColors.textMutedL,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _styles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final (label, imagePath, color) = _styles[i];
                return GestureDetector(
                  onTap: () => context.push('/upload'),
                  child: Container(
                    width: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          Image.asset(
                            imagePath,
                            width: 190,
                            height: 260,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    'TRENDING',
                                    style: AppTextStyles.overline.copyWith(
                                      color: AppColors.backgroundLight,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  label,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentDesigns extends StatelessWidget {
  final Function(int) onTabChange;
  const _RecentDesigns({required this.onTabChange});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<DesignBloc, DesignState>(
      builder: (context, state) {
        if (state is! DesignHistoryLoaded || state.designs.isEmpty) {
          return const SizedBox.shrink();
        }
        final recent = state.designs.take(5).toList();
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT CREATIONS',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.textMutedL,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Use the internal state change instead of router to avoid "Page not found" if any router issues
                        onTabChange(1);
                      },
                      child: Text(
                        'View All',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: recent.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, i) {
                    final d = recent[i];
                    return Hero(
                      tag: 'design_${d.id}',
                      child: Container(
                        width: 170,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: _DesignCard(
                          design: d,
                          onTap: () => context.push('/result', extra: d),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid();
  static const _features = [
    (
      'AI Render',
      Icons.auto_awesome_rounded,
      'Photo-realistic',
      AppColors.primary,
      '/upload',
    ),
    (
      'Moodboards',
      Icons.dashboard_rounded,
      'Curate palettes',
      AppColors.badgePink,
      '/moodboards',
    ),
    (
      'Furniture',
      Icons.chair_rounded,
      'Shop items',
      AppColors.badgeBlue,
      '/furniture',
    ),
    (
      '3D Layout',
      Icons.view_in_ar_rounded,
      'Spatial planning',
      AppColors.badgePurple,
      '/layouts',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isPremium = authState is AuthAuthenticated && authState.user.isPremium;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRO FEATURES',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark ? AppColors.textMuted : AppColors.textMutedL,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.4,
                ),
                itemCount: _features.length,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  final (title, icon, sub, color, route) = _features[i];
                  return GestureDetector(
                    onTap: () {
                      if (route == '/upload') {
                        context.push(route);
                        return;
                      }
                      
                      if (!isPremium) {
                        context.push('/pricing');
                        return;
                      }

                      if (route == '/pricing') {
                        // This shouldn't happen if isPremium is true, but for safety:
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$title is coming soon for Pro users!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      } else {
                        context.push(route);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : AppColors.borderL,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, size: 22, color: color),
                              ),
                              if (!isPremium)
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 16,
                                  color: isDark ? Colors.white24 : Colors.black12,
                                ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            title,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.textPrimaryL,
                            ),
                          ),
                          Text(
                            sub,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isDark
                                  ? AppColors.textMuted
                                  : AppColors.textMutedL,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── History Tab ─────────────────────────────────────────────────────────────
class HistoryTab extends StatelessWidget {
  final bool showSavedOnly;
  const HistoryTab({super.key, this.showSavedOnly = false});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<DesignBloc, DesignState>(
      builder: (context, state) {
        final authState = context.read<AuthBloc>().state;
        return RefreshIndicator(
          onRefresh: () async {
            if (authState is AuthAuthenticated) {
              context.read<DesignBloc>().add(
                DesignLoadHistory(userId: authState.user.id),
              );
            }
            await Future.delayed(const Duration(milliseconds: 800));
          },
          color: AppColors.primary,
          backgroundColor: Theme.of(context).cardColor,
          edgeOffset: 100,
          child: CustomScrollView(
            key: const PageStorageKey('history_scroll'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Designs',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textPrimaryL,
                        ),
                      ),
                      Text(
                        'Your collection of AI-powered masterpieces',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryL,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state is DesignHistoryLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (state is DesignHistoryLoaded && state.designs.isNotEmpty)
                Builder(builder: (context) {
                  final designs = showSavedOnly
                      ? state.designs.where((d) => d.isFavorite).toList()
                      : state.designs;

                  if (designs.isEmpty && showSavedOnly) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No saved designs yet',
                          style: GoogleFonts.poppins(
                            color: isDark ? AppColors.textMuted : AppColors.textMutedL,
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate((context, i) {
                        final d = designs[i];
                        return _DesignCard(
                          design: d,
                          onTap: () => context.push('/result', extra: d),
                        );
                      }, childCount: designs.length),
                    ),
                  );
                })
              else
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          shape: BoxShape.circle,
                          child: Icon(
                            Icons.camera_rounded,
                            size: 48,
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No designs yet',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload a room photo to get started',
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 200,
                          child: PrimaryButton(
                            label: 'Create First Design',
                            onPressed: () {
                              // Navigate to home tab (upload)
                              // This depends on how HomeScreen handles tab switching
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }
}

class _DesignCard extends StatelessWidget {
  final dynamic design;
  final VoidCallback? onTap;
  const _DesignCard({required this.design, this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl:
                      design.generatedImagePath ?? design.originalImagePath,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05),
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      color: isDark ? Colors.white24 : Colors.black12,
                      size: 32,
                    ),
                  ),
                ),
                // Style Overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Row(
                      children: [
                        SmartIcon(
                          design.styleIcon,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            design.styleLabel,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favorite Indicator
                if (design.isFavorite)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.error,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        design.budgetLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Refined Room', // Or some other dynamic name if available
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimaryL,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Tab ─────────────────────────────────────────────────────────────
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) return const SizedBox.shrink();
        final user = state.user;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<AuthBloc>().add(AuthRefreshRequested());
            await Future.delayed(const Duration(milliseconds: 800));
          },
          color: AppColors.primary,
          backgroundColor: Theme.of(context).cardColor,
          child: CustomScrollView(
            key: const PageStorageKey('profile_scroll'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Premium Header Section
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background Mesh/Glow
                    Container(
                      height: 220,
                      width: double.infinity,
                      child: const MeshGradient(),
                    ),

                    // User Info Layer
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          // Avatar
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.primaryGradient,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                  image: user.photoUrl != null
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            user.photoUrl!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: user.photoUrl == null
                                    ? Center(
                                        child: Text(
                                          user.name.isNotEmpty
                                              ? user.name[0].toUpperCase()
                                              : 'U',
                                          style: AppTextStyles.displayLarge
                                              .copyWith(
                                                fontSize: 42,
                                                color: Colors.white,
                                              ),
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => context.push('/edit-profile'),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.name,
                            style: AppTextStyles.headlineLarge.copyWith(
                              fontSize: 26,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimaryL,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textMuted
                                  : AppColors.textSecondaryL,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Stats Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
                  child: Row(
                    children: [
                      _StatCard(
                        label: 'Credits',
                        value: '${user.freeDesignsLeft}',
                        icon: Icons.bolt_rounded,
                        color: AppColors.badgeAmber,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Created',
                        value:
                            '12', // Placeholder - should come from design history count
                        icon: Icons.auto_awesome_mosaic_rounded,
                        color: AppColors.badgePurple,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Status',
                        value: user.isPremium ? 'PRO' : 'FREE',
                        icon: user.isPremium
                            ? Icons.stars_rounded
                            : Icons.person_outline_rounded,
                        color: user.isPremium
                            ? AppColors.primary
                            : AppColors.accent,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Upgrade Banner (if not premium)
              if (!user.isPremium)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: GestureDetector(
                      onTap: () => context.push('/pricing'),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Upgrade to HomiQ Pro',
                                    style: AppTextStyles.titleLarge.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Unlimited designs & premium styles',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Settings Groups
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SettingsGroup(
                      title: 'Account Settings',
                      children: [
                        _ProfileTile(
                          icon: Icons.person_outline_rounded,
                          label: 'Edit Profile',
                          onTap: () => context.push('/edit-profile'),
                        ),
                        _ProfileTile(
                          icon: Icons.stars_rounded,
                          label: 'My Subscription',
                          onTap: () => context.push('/subscription'),
                        ),
                        _ProfileTile(
                          icon: Icons.notifications_none_rounded,
                          label: 'Notifications',
                          onTap: () => context.push('/notifications'),
                        ),
                        _ProfileTile(
                          icon: Icons.language_rounded,
                          label: 'Language',
                          trailing: BlocBuilder<LanguageCubit, Locale>(
                            builder: (context, locale) {
                              final languageName =
                                  switch (locale.languageCode) {
                                    'en' => 'English',
                                    'hi' => 'Hindi',
                                    'es' => 'Spanish',
                                    'fr' => 'French',
                                    'ar' => 'Arabic',
                                    _ => 'English',
                                  };
                              return Text(
                                languageName,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              );
                            },
                          ),
                          onTap: () => _showLanguageDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SettingsGroup(
                      title: 'Preferences',
                      children: [
                        BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, mode) {
                            return _ProfileTile(
                              icon: mode == ThemeMode.dark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              label: 'Dark Mode',
                              trailing: CupertinoSwitch(
                                value: mode == ThemeMode.dark,
                                activeTrackColor: AppColors.primary,
                                onChanged: (_) =>
                                    context.read<ThemeCubit>().toggleTheme(),
                              ),
                              onTap: () =>
                                  context.read<ThemeCubit>().toggleTheme(),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SettingsGroup(
                      title: 'More',
                      children: [
                        _ProfileTile(
                          icon: Icons.shield_outlined,
                          label: 'Privacy Policy',
                          onTap: () => context.push('/privacy-policy'),
                        ),
                        _ProfileTile(
                          icon: Icons.help_outline_rounded,
                          label: 'Help & Support',
                          onTap: () => context.push('/help-support'),
                        ),
                        _ProfileTile(
                          icon: Icons.logout_rounded,
                          label: 'Sign Out',
                          isDestructive: true,
                          onTap: () => _showSignOutConfirmation(context),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: GlassCard(
            padding: const EdgeInsets.all(28),
            borderRadius: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.signOutConfirmTitle,
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontSize: 24,
                    color: isDark ? Colors.white : AppColors.textPrimaryL,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.signOutConfirmMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryL,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryL,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: l10n.confirm,
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                          context.go('/login');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == .dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Language',
              style: AppTextStyles.headlineSmall.copyWith(
                fontSize: 22,
                color: isDark ? Colors.white : AppColors.textPrimaryL,
              ),
            ),
            const SizedBox(height: 24),
            const _LanguageTile(label: 'English', code: 'en', icon: '🇺🇸'),
            const _LanguageTile(label: 'Hindi', code: 'hi', icon: '🇮🇳'),
            const _LanguageTile(label: 'Spanish', code: 'es', icon: '🇪🇸'),
            const _LanguageTile(label: 'French', code: 'fr', icon: '🇫🇷'),
            const _LanguageTile(label: 'Arabic', code: 'ar', icon: '🇦🇪'),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark ? AppColors.textMuted : AppColors.textMutedL,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: 24,
          child: Column(
            children: children.asMap().entries.map((entry) {
              final idx = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (idx < children.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05),
                        height: 1,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        borderRadius: 20,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                fontSize: 18,
                color: isDark ? Colors.white : AppColors.textPrimaryL,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                color: isDark ? AppColors.textMuted : AppColors.textMutedL,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDestructive
                        ? AppColors.error
                        : (isDark ? Colors.white : AppColors.textPrimaryL),
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.white24 : Colors.black26,
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final String code;
  final String icon;

  const _LanguageTile({
    required this.label,
    required this.code,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        final isSelected = locale.languageCode == code;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.read<LanguageCubit>().changeLanguage(code);
              context.pop();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.white : AppColors.textPrimaryL),
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
