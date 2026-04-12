import 'package:flutter/material.dart';
import 'package:homiq/utils/custom_image.dart';
import 'package:homiq/utils/extensions/extensions.dart';
import 'package:homiq/utils/extensions/lib/custom_text.dart';
import 'package:homiq/utils/responsive_size.dart';

class AgentProfileWidget extends StatelessWidget {
  final String addedBy;
  final String name;
  final String email;
  final String profileImage;
  final bool isVerified;
  final String propertiesCount;
  final String projectsCount;

  const AgentProfileWidget({
    super.key,
    required this.addedBy,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.isVerified,
    required this.propertiesCount,
    required this.projectsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CustomImage(
                imageUrl: profileImage,
                width: 40.rw(context),
                height: 40.rh(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomText(
                        name,
                        fontWeight: FontWeight.w600,
                        fontSize: context.font.md,
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 16, color: Colors.blue),
                      ],
                    ],
                  ),
                  CustomText(
                    email,
                    fontSize: context.font.sm,
                    color: context.color.textColorDark.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStat(context, propertiesCount, 'Properties'),
            const SizedBox(width: 24),
            _buildStat(context, projectsCount, 'Projects'),
          ],
        ),
      ],
    );
  }

  Widget _buildStat(BuildContext context, String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(count, fontWeight: FontWeight.bold, fontSize: context.font.md),
        CustomText(label, fontSize: context.font.xs, color: context.color.textColorDark.withOpacity(0.6)),
      ],
    );
  }
}
