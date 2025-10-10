import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:homiq/app/routes.dart';
import 'package:homiq/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:homiq/data/model/system_settings_model.dart';
import 'package:homiq/utils/Extensions/extensions.dart';
import 'package:homiq/utils/custom_image.dart';
import 'package:homiq/utils/extensions/lib/custom_text.dart';
import 'package:homiq/utils/hive_keys.dart';
import 'package:homiq/utils/responsive_size.dart';
import 'package:homiq/utils/ui_utils.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int currentPageIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slidersList = [
      {
        'img': 'assets/svg/on_1.svg',
        'title': UiUtils.translate(context, 'Welcome To Homiq'),
        'description': UiUtils.translate(context, 'onboarding_1_description'),
      },
      {
        'img': 'assets/svg/on_2.svg',
        'title': UiUtils.translate(context, 'onboarding_2_title'),
        'description': UiUtils.translate(context, 'onboarding_2_description'),
      },
      {
        'img': 'assets/svg/on_3.svg',
        'title': UiUtils.translate(context, 'onboarding_3_title'),
        'description': UiUtils.translate(context, 'onboarding_3_description'),
      },
    ];

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentPageIndex = index;
                    });
                    _animationController
                      ..reset()
                      ..forward();
                  },
                  itemCount: slidersList.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(
                      context,
                      slidersList[index],
                      index,
                    );
                  },
                ),
              ),
              _buildBottomSection(context, slidersList.length),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLanguageSelector(context),
          _buildSkipButton(context),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await context.read<FetchSystemSettingsCubit>().fetchSettings(
              isAnonymous: true,
            );
        await Navigator.pushNamed(
          context,
          Routes.languageListScreenRoute,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.color.primaryColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: context.color.borderColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder(
              stream: Hive.box<dynamic>(HiveKeys.languageBox)
                  .watch(key: HiveKeys.currentLanguageKey),
              builder: (context, AsyncSnapshot<BoxEvent> value) {
                final language = context
                    .watch<FetchSystemSettingsCubit>()
                    .getSetting(SystemSetting.language)
                    .toString()
                    .firstUpperCase();

                if (value.data?.value == null) {
                  if (language == 'null') {
                    return const CustomText('');
                  }
                  return CustomText(
                    language,
                    color: context.color.textColorDark,
                    fontSize: context.font.sm,
                    fontWeight: FontWeight.w600,
                  );
                } else {
                  return CustomText(
                    value.data!.value!['code'].toString().firstUpperCase(),
                    color: context.color.textColorDark,
                    fontSize: context.font.sm,
                    fontWeight: FontWeight.w600,
                  );
                }
              },
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: context.color.textColorDark,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, Routes.login);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: context.color.tertiaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: CustomText(
          'skip'.translate(context),
          color: context.color.tertiaryColor,
          fontSize: context.font.sm,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
      BuildContext context, Map<String, dynamic> data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: 'onboarding_image_$index',
            child: SizedBox(
              height: 300.rh(context),
              width: 300.rw(context),
              child: CustomImage(
                imageUrl: data['img'].toString(),
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 40.rh(context)),
          CustomText(
            data['title']?.toString() ?? '',
            fontWeight: FontWeight.w700,
            fontSize: context.font.xxl,
            color: context.color.tertiaryColor,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.rh(context)),
          CustomText(
            data['description']?.toString() ?? '',
            maxLines: 3,
            textAlign: TextAlign.center,
            fontSize: context.font.md,
            color: context.color.textColorDark,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, int totalPages) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              totalPages,
              (index) => _buildIndicator(context, index == currentPageIndex),
            ),
          ),
          _buildNextButton(context, totalPages),
        ],
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? context.color.tertiaryColor
            : context.color.textColorDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, int totalPages) {
    return GestureDetector(
      onTap: () {
        if (currentPageIndex < totalPages - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.login,
            (route) => false,
          );
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.color.tertiaryColor,
              context.color.tertiaryColor.withValues(alpha: 0.8),
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          currentPageIndex < totalPages - 1
              ? Icons.arrow_forward_rounded
              : Icons.check_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
