import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../bloc/subscription/subscription_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});
  @override
  State<PricingScreen> createState() => _PricingScreenState();
}
class _PricingScreenState extends State<PricingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.defaultCurve,
    ));
    _controller.forward();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: isDark ? Colors.white : AppColors.textPrimaryL),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          const MeshGradient(),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 100, 24, 0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.stars_rounded,
                                size: 48, color: Colors.white),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Homiq Pro',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimaryL,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Personal AI Interior Designer',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
                        listener: (context, state) {
                          if (state.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.error!),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                          if (state.isPremium) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Welcome to the elite club!'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            context.pop();
                          }
                        },
                        builder: (context, state) {
                          final authState = context.read<AuthBloc>().state;
                          final bool isActuallyPremium =
                              (authState is AuthAuthenticated &&
                                      authState.user.isPremium) ||
                                  state.isPremium;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GlassCard(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    _buildFeatureRow(
                                        Icons.all_inclusive_rounded,
                                        'Unlimited Everything',
                                        'Never wait for a design again'),
                                    _buildFeatureRow(
                                        Icons.high_quality_rounded,
                                        'Ultra-HD Exports',
                                        'Crystal clear designs for any screen'),
                                    _buildFeatureRow(
                                        Icons.auto_awesome_rounded,
                                        'Exclusive Styles',
                                        'Access to premium architectural styles'),
                                    _buildFeatureRow(
                                        Icons.support_agent_rounded,
                                        'Elite Support',
                                        'Priority access to our design team'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              if (state.isLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (state.products.isEmpty)
                                _buildPricingCard(
                                  'Pro Plan',
                                  '₹799',
                                  'per month',
                                  'Elevate your space with unlimited AI power and professional tools.',
                                  isActuallyPremium
                                      ? null
                                      : () => _simulatePurchase(context),
                                  context,
                                  buttonLabel: isActuallyPremium
                                      ? 'Active Plan'
                                      : 'Start My Free Trial',
                                )
                              else
                                ...state.products.map((p) => _buildPricingCard(
                                      p.title,
                                      p.price,
                                      '',
                                      p.description,
                                      isActuallyPremium
                                          ? null
                                          : () => context
                                              .read<SubscriptionBloc>()
                                              .add(
                                                  SubscriptionPurchaseRequested(
                                                      p)),
                                      context,
                                      buttonLabel: isActuallyPremium
                                          ? 'Active Plan'
                                          : 'Upgrade Now',
                                    )),
                              const SizedBox(height: 24),
                              Center(
                                child: TextButton(
                                  onPressed: () => context
                                      .read<SubscriptionBloc>()
                                      .add(SubscriptionRestoreRequested()),
                                  child: Text(
                                    'Restore Purchase',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimaryL,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPricingCard(String title, String price, String period,
      String desc, VoidCallback? onTap, BuildContext context,
      {String buttonLabel = 'Start Pro Plan'}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.all(32),
      borderRadius: 32,
      border:
          Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimaryL,
                ),
              ),
              if (period.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 4),
                  child: Text(
                    period,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              height: 1.5,
              fontSize: 14,
              color:
                  isDark ? AppColors.textSecondary : AppColors.textSecondaryL,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: buttonLabel,
            onPressed: onTap,
            icon: Icons.bolt_rounded,
          ),
          if (onTap != null) ...[
            const SizedBox(height: 12),
            Text(
              'No commitment. Cancel anytime.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ),
          ],
        ],
      ),
    );
  }
  void _simulatePurchase(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting premium checkout...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
