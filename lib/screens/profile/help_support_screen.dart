import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Help & Support',
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
                Text(
                  'How can we help?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimaryL,
                  ),
                ),
                Text(
                  'Check out our FAQs or get in touch',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: isDark ? AppColors.textSecondary : AppColors.textSecondaryL,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Support Channels
                Row(
                  children: [
                    Expanded(
                      child: _SupportCard(
                        icon: Icons.mail_outline_rounded,
                        label: 'Email Support',
                        onTap: () => _launchUrl('mailto:support@homiq.ai'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SupportCard(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'WhatsApp',
                        onTap: () => _launchUrl('https://wa.me/918454044540'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                Text(
                  'Frequently Asked Questions', 
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimaryL,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildFaqTile(
                  'How many designs do I get for free?',
                  'New users get 3 free high-quality AI designs to start their journey. You can upgrade to a Pro plan for unlimited designs.',
                  context
                ),
                _buildFaqTile(
                  'Can I save my designs?',
                  'Yes! You can bookmark any design you love, and it will be saved in your "My Designs" tab for future reference.',
                  context
                ),
                _buildFaqTile(
                  'What image format works best?',
                  'Clear, well-lit photos taken from a doorway or corner work best. Avoid dark or very blurry photos for the most accurate results.',
                  context
                ),
                _buildFaqTile(
                  'Is my data secure?',
                  'Absolutely. We use industry-standard encryption to protect your photos and personal information. Read our Privacy Policy for more details.',
                  context
                ),
                
                const SizedBox(height: 48),
                PrimaryButton(
                  label: 'Chat with us',
                  icon: Icons.message_rounded,
                  onPressed: () => _launchUrl('https://homiq.ai/chat'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isDark ? Colors.white : AppColors.textPrimaryL,
            ),
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: isDark ? Colors.white24 : Colors.black26,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.topLeft,
          children: [
            Text(
              answer,
              style: GoogleFonts.poppins(
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryL,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SupportCard({
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
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              label, 
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimaryL,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
