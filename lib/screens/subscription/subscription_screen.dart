import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homiq_ai/services/subscription_service.dart';
import 'package:homiq_ai/theme/app_theme.dart';
import 'package:homiq_ai/widgets/common_widgets.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late SubscriptionService _subscriptionService;
  bool _isLoading = true;
  Map<String, dynamic>? _subscriptionData;

  @override
  void initState() {
    super.initState();
    _subscriptionService = SubscriptionService(Dio(BaseOptions(
      baseUrl: 'https://homiq.acrocoder.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    )));
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final data = await _subscriptionService.getSubscriptionStatus();
      setState(() {
        _subscriptionData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load subscription status')),
        );
      }
    }
  }

  Future<void> _manageSubscription() async {
    final sub = _subscriptionData?['subscription'];
    if (sub == null) return;

    final platform = sub['platform'];
    Uri url;

    if (platform == 'ios') {
      url = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else if (platform == 'android') {
      url = Uri.parse('https://play.google.com/store/account/subscriptions');
    } else {
      return;
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sub = _subscriptionData?['subscription'];
    final isPremium = _subscriptionData?['is_premium'] ?? false;

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
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'My Subscription',
                style: GoogleFonts.playfairDisplay(
                  color: isDark ? Colors.white : AppColors.textPrimaryL,
                  fontWeight: FontWeight.w800,
                ),
              ),
              centerTitle: true,
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatusCard(isDark, isPremium, sub),
                  const SizedBox(height: 32),
                  if (sub != null) ...[
                    _buildDetailsCard(isDark, sub),
                    const SizedBox(height: 32),
                    _buildCancellationCard(isDark, _subscriptionData?['cancellation_instructions']),
                  ] else ...[
                    _buildNoSubscriptionCard(isDark),
                  ],
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isDark, bool isPremium, dynamic sub) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 32,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (isPremium ? AppColors.primary : AppColors.textMuted).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPremium ? Icons.stars_rounded : Icons.person_outline_rounded,
              color: isPremium ? AppColors.primary : AppColors.textMuted,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isPremium ? 'HomiQ Pro Active' : 'HomiQ Free Plan',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimaryL,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isPremium ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPremium ? 'ACTIVE' : 'INACTIVE',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(bool isDark, dynamic sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'BILLING DETAILS',
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark ? AppColors.textMuted : AppColors.textMutedL,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.all(0),
          borderRadius: 24,
          child: Column(
            children: [
              _buildInfoRow('Plan Name', sub['package_name'], isDark),
              const Divider(height: 1),
              _buildInfoRow('Amount', '${sub['amount']} ${sub['currency'] ?? 'INR'}', isDark),
              const Divider(height: 1),
              _buildInfoRow('Renewal Date', _formatDate(sub['end_date']), isDark),
              const Divider(height: 1),
              _buildInfoRow('Platform', (sub['platform'] as String).toUpperCase(), isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryL,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimaryL,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationCard(bool isDark, String? instructions) {
    return Column(
      children: [
        Text(
          instructions ?? 'You can manage your subscription via your store account settings.',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.textMuted : AppColors.textMutedL,
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Manage Subscription',
          onPressed: _manageSubscription,
        ),
      ],
    );
  }

  Widget _buildNoSubscriptionCard(bool isDark) {
    return Column(
      children: [
        Text(
          'Unlock the full potential of AI with HomiQ Pro. Get unlimited designs, HD resolution, and exclusive room styles.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryL,
          ),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'View Pro Plans',
          onPressed: () => Navigator.pushNamed(context, '/pricing'),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_getMonth(date.month)} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
