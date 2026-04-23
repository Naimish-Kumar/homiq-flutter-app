import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homiq_ai/widgets/common_widgets.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: isDark ? Colors.white : AppColors.textPrimaryL,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: isDark ? Colors.white : AppColors.textPrimaryL),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          const MeshGradient(),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  'Introduction',
                  'Welcome to Homiq AI. We value your privacy and are committed to protecting your personal data. This privacy policy will inform you as to how we look after your personal data when you visit our website or use our mobile application.',
                  context
                ),
                _buildSection(
                  'Data We Collect',
                  'We may collect, use, store and transfer different kinds of personal data about you which we have grouped together as follows:\n\n• Identity Data: Name, username.\n• Contact Data: Email address, phone number.\n• Technical Data: IP address, device type, operating system.\n• Usage Data: Information about how you use our app and services.',
                  context
                ),
                _buildSection(
                  'How We Use Your Data',
                  'We will only use your personal data when the law allows us to. Most commonly, we will use your personal data in the following circumstances:\n\n• To register you as a new customer.\n• To process and deliver your interior designs.\n• To manage our relationship with you.\n• To improve our application and services.',
                  context
                ),
                _buildSection(
                  'AI Data Processing',
                  'Our AI processing involves analyzing your uploaded images to generate interior designs. These images are stored securely and are only used for the purpose of providing you with the requested services. We do not sell your images to third parties.',
                  context
                ),
                _buildSection(
                  'Your Rights',
                  'You have the right to:\n\n• Request access to your personal data.\n• Request correction of your personal data.\n• Request erasure of your personal data.\n• Object to processing of your personal data.',
                  context
                ),
                _buildSection(
                  'Contact Us',
                  'If you have any questions about this privacy policy or our privacy practices, please contact us at support@homiq.ai.',
                  context
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Last Updated: April 2026',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? AppColors.textMuted : AppColors.textMutedL,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: GoogleFonts.poppins(
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryL,
                height: 1.7,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
