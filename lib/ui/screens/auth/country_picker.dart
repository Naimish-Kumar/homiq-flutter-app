// Country picker widget to encapsulate country selection functionality
import 'package:flutter/material.dart';
import 'package:homiq/utils/app_icons.dart';
import 'package:homiq/utils/custom_image.dart';
import 'package:homiq/utils/extensions/extensions.dart';
import 'package:homiq/utils/extensions/lib/custom_text.dart';
import 'package:homiq/utils/responsive_size.dart';

class CountryPickerWidget extends StatelessWidget {
  const CountryPickerWidget({
    required this.flagEmoji,
    required this.onTap,
    super.key,
  });
  final String? flagEmoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.only(
            start: 16.0,
          ),
          height: 48.rh(context),
          alignment: Alignment.center,
          child: Row(
            children: [
              CustomText(
                flagEmoji ?? '',
                fontSize: context.font.xxl,
              ),
              const SizedBox(width: 8.0),
              CustomImage(
                imageUrl: AppIcons.downArrow,
                height: 16.rh(context),
                width: 16.rw(context),
                color: context.color.tertiaryColor,
              ),
              const SizedBox(width: 8.0),
              Container(
                height: 24.rh(context),
                width: 1,
                color: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
