import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:homiq/app/routes.dart';
import 'package:homiq/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:homiq/data/model/system_settings_model.dart';
import 'package:homiq/utils/extensions/extensions.dart';
import 'package:homiq/utils/app_icons.dart' show AppIcons;
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
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slidersList = [
      {
        'image': AppIcons.onBoardingOne,
        'title': 'AI Transformation',
        'subtitle': 'REIMAGINE YOUR SPACE',
        'description':
            'Experience the future of interior design. Our advanced AI analyzes your room and generates photorealistic concepts in seconds.',
        'color': context.color.tertiaryColor,
      },
      {
        'image': AppIcons.onBoardingTwo,
        'title': 'Tailored Styles',
        'subtitle': 'CURATE YOUR AESTHETIC',
        'description':
            'From Scandinavian Minimalism to Modern Industrial. Discover the perfect style that resonates with your unique personality.',
        'color': context.color.accentColor,
      },
      {
        'image': AppIcons.onBoardingThree,
        'title': 'Instant High fidelity',
        'subtitle': 'PROFESSIONAL RESULTS',
        'description':
            'Get professional-grade renderings instantly. Visualize furniture, lighting, and colors with unparalleled clarity and detail.',
        'color': context.color.tertiaryColor,
      },
    ];

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildTopBar(context),
                Hero(
                  tag: 'splash_logo',
                  child: Container(
                    height: 80.rh(context),
                    margin: EdgeInsets.symmetric(vertical: 20.rh(context)),
                    child: CustomImage(
                      imageUrl: AppIcons.splashLogo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentPageIndex = index;
                      });
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
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: context.color.secondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
              color: context.color.borderColor.withOpacity(0.3)),
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
            const SizedBox(width: 6),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: context.color.tertiaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: CustomText(
          'Skip',
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
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 420.rh(context),
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: context.color.textColorDark.withValues(alpha: 0.05),
                  blurRadius: 40,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                data['image'] as String,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 40.rh(context)),
          CustomText(
            data['subtitle']?.toString() ?? '',
            fontWeight: FontWeight.w500,
            fontSize: context.font.md,
            color: context.color.textColorDark.withOpacity(0.7),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.rh(context)),
          CustomText(
            data['title']?.toString() ?? '',
            fontWeight: FontWeight.w700,
            fontSize: context.font.xxl,
            color: context.color.textColorDark,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.rh(context)),
          CustomText(
            data['description']?.toString() ?? '',
            maxLines: 3,
            textAlign: TextAlign.center,
            fontSize: context.font.md,
            color: context.color.textColorDark.withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, int totalPages) {
    return Container(
      padding: const EdgeInsets.all(32),
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
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(right: 10),
      height: 6,
      width: isActive ? 32 : 6,
      decoration: BoxDecoration(
        color: isActive
            ? context.color.tertiaryColor
            : context.color.textColorDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, int totalPages) {
    return GestureDetector(
      onTap: () {
        if (currentPageIndex < totalPages - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
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
          color: context.color.tertiaryColor,
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
