import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../../utils/extensions/extensions.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;

  const CustomBackButton({
    super.key,
    this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: iconColor ?? context.color.textColorDark,
        size: 20,
      ),
      onPressed: onPressed ?? () => Navigator.pop(context),
    );
  }
}
