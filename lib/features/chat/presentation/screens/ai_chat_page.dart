import 'package:flutter/material.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/utils/custom_appbar.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: CustomAppBar(
        title: CustomText('AI Help'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: context.color.tertiaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            CustomText(
              'Virtual Assistant Coming Soon',
              fontSize: context.font.lg,
              fontWeight: FontWeight.bold,
              color: context.color.textColorDark,
            ),
            const SizedBox(height: 10),
            CustomText(
              'Your personal virtual interior designer is on its way!',
              fontSize: context.font.sm,
              color: context.color.textLightColor,
            ),
          ],
        ),
      ),
    );
  }
}
