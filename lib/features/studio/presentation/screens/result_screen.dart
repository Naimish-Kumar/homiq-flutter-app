import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/features/studio/presentation/widgets/before_after_slider.dart';
import 'package:homiq/utils/custom_image.dart';

class ResultScreen extends StatelessWidget {
  final dynamic originalImage; // Can be File or String (URL)
  final String resultImageUrl;
  final String? styleName;

  const ResultScreen({
    super.key,
    required this.originalImage,
    required this.resultImageUrl,
    this.styleName,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        body: Stack(
          children: [
            // Luxury Background
            Container(decoration: BoxDecoration(gradient: context.color.meshGradient)),
            
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleSection(context),
                          const SizedBox(height: 32),
                          _buildSliderCard(context),
                          const SizedBox(height: 48),
                          _buildActions(context),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: context.color.textColorDark),
            onPressed: () => Navigator.pop(context),
          ),
          const CustomText(
            'TRANSFORMATION',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 6,
            useSerif: true,
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: context.color.textColorDark),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          styleName?.toUpperCase() ?? 'MODERN AESTHETIC',
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: context.color.tertiaryColor,
        ),
        const SizedBox(height: 8),
        const CustomText(
          'Vision Realized',
          fontSize: 32,
          fontWeight: FontWeight.w900,
          useSerif: true,
        ),
      ],
    );
  }

  Widget _buildSliderCard(BuildContext context) {
    Widget beforeWidget;
    if (originalImage is File) {
      beforeWidget = Image.file(originalImage as File, fit: BoxFit.cover);
    } else if (originalImage is String) {
      beforeWidget = CustomImage(imageUrl: originalImage as String, fit: BoxFit.cover);
    } else {
      beforeWidget = const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: 450,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BeforeAfterSlider(
          beforeImage: beforeWidget,
          afterImage: CustomImage(
            imageUrl: resultImageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: context.color.tertiaryColor.withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: context.color.tertiaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const CustomText(
              'DOWNLOAD CONCEPT',
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide(color: context.color.tertiaryColor.withValues(alpha: 0.3)),
          ),
          child: CustomText(
            'TRY ANOTHER STYLE',
            color: context.color.tertiaryColor,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
