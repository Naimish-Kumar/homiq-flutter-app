import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homiq_ai/widgets/common_widgets.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: isDark ? Colors.white : AppColors.textPrimaryL,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : AppColors.textPrimaryL,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () async {
                await context.read<NotificationService>().markAllAsRead();
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'All notifications marked as read',
                        style: GoogleFonts.poppins(),
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: Text(
                'Mark all read',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const MeshGradient(),
          RefreshIndicator(
            onRefresh: () async {
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppColors.primary,
            backgroundColor: isDark ? AppColors.surface : Colors.white,
            edgeOffset: 100,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: context.read<NotificationService>().getNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == .waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notes = snapshot.data ?? [];

                if (notes.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: .min,
                          children: [
                            GlassCard(
                              padding: const .all(24),
                              shape: .circle,
                              child: Icon(
                                Icons.notifications_off_rounded,
                                size: 48,
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No notifications yet',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: .w700,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimaryL,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const .fromLTRB(24, 120, 24, 24),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _NotificationTile(note: notes[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> note;
  const _NotificationTile({required this.note});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isUnread = note['isUnread'] ?? false;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      border: isUnread
          ? Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUnread
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : (isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SmartIcon(
              note['icon'] ?? Icons.notifications_rounded,
              size: 20,
              color: isUnread
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryL),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      note['title'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.textPrimaryL,
                      ),
                    ),
                    Text(
                      note['time'],
                      style: GoogleFonts.poppins(
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.textMutedL,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  note['body'],
                  style: GoogleFonts.poppins(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryL,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
