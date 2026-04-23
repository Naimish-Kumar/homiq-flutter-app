import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../bloc/subscription/subscription_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends State<SubscriptionManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(SubscriptionLoadActive());
  }

  void _manageSubscription() async {
    final String url;
    if (Platform.isAndroid) {
      url = 'https://play.google.com/store/account/subscriptions';
    } else {
      url = 'https://apps.apple.com/account/subscriptions';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Subscription',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimaryL,
          ),
        ),
      ),
      body: Stack(
        children: [
          const MeshGradient(),
          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final sub = state.activeSubscription;
              if (sub == null) {
                return _buildNoActiveSubscription(isDark);
              }

              return _buildActiveSubscription(sub, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveSubscription(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_membership_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Subscription',
              style: AppTextStyles.headlineMedium.copyWith(
                color: isDark ? Colors.white : AppColors.textPrimaryL,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upgrade to HomiQ Pro to unlock all premium features and unlimited designs.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textMuted : AppColors.textSecondaryL,
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'View Plans',
              onPressed: () => Navigator.of(context).pushNamed('/pricing'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSubscription(Map<String, dynamic> sub, bool isDark) {
    final name = sub['package_name'] ?? 'Pro';
    final status = sub['status'] ?? 'active';
    final endDate = sub['end_date'] != null 
        ? DateTime.parse(sub['end_date'].toString()) 
        : null;
    final amount = sub['amount'] ?? '0';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.stars_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HomiQ $name Plan',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: isDark ? Colors.white : AppColors.textPrimaryL,
                            ),
                          ),
                          Text(
                            status.toUpperCase(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 24),
                _buildInfoRow('Billing Amount', '₹$amount/month', isDark),
                if (endDate != null) ...[
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    sub['auto_renew'] == false ? 'Expires on' : 'Next Renewal', 
                    DateFormat('MMM dd, yyyy').format(endDate), 
                    isDark
                  ),
                ],
                if (sub['auto_renew'] == false) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your subscription has been cancelled and will not renew.',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _buildInfoRow('Payment Platform', sub['platform']?.toString().toUpperCase() ?? 'STORE', isDark),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Manage Subscription',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimaryL,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You can change or cancel your subscription at any time through your app store account settings.',
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.textMuted : AppColors.textSecondaryL,
            ),
          ),
          const SizedBox(height: 24),
          _ProfileTile(
            icon: Icons.open_in_new_rounded,
            label: 'Open App Store Settings',
            onTap: _manageSubscription,
          ),
          const SizedBox(height: 12),
          _ProfileTile(
            icon: Icons.receipt_long_rounded,
            label: 'Billing History',
            onTap: () {
               // Placeholder for billing history
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Billing history coming soon')),
               );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textMuted : AppColors.textSecondaryL,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimaryL,
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimaryL,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
