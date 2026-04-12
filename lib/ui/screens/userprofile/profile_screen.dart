import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsis;
import 'package:homiq/data/cubits/auth/get_user_data_cubit.dart';
import 'package:homiq/data/model/system_settings_model.dart';
import 'package:homiq/data/repositories/auth_repository.dart';
import 'package:homiq/data/repositories/system_repository.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/ui/screens/home/widgets/custom_refresh_indicator.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  String verificationStatus = '';
  bool isGuest = false;
  final ScrollController profileScreenController = ScrollController();
  @override
  void initState() {
    final settings = context.read<FetchSystemSettingsCubit>();

    isGuest = GuestChecker.value;
    GuestChecker.listen().addListener(() {
      isGuest = GuestChecker.value;
      if (mounted) setState(() {});
    });
    if (!const bool.fromEnvironment(
      'force-disable-demo-mode',
    )) {
      Constant.isDemoModeOn =
          settings.getSetting(SystemSetting.demoMode) as bool? ?? false;
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  bool get wantKeepAlive => true;
  int? a;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settings = context.watch<FetchSystemSettingsCubit>();
    verificationStatus =
        settings.getSetting(SystemSetting.verificationStatus)?.toString() ?? '';
    if (!const bool.fromEnvironment(
      'force-disable-demo-mode',
    )) {
      Constant.isDemoModeOn =
          settings.getSetting(SystemSetting.demoMode) as bool? ?? false;
    }
    var username = 'anonymous'.translate(context);
    var email = 'notLoggedIn'.translate(context);
    if (!isGuest) {
      final user = context.watch<UserDetailsCubit>().state.user;
      username = user?.name!.firstUpperCase() ?? 'anonymous'.translate(context);
      email = user?.email ?? 'notLoggedIn'.translate(context);
    }
    final systemSettingsState = context.read<FetchSystemSettingsCubit>().state;

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: CustomAppBar(
          title: CustomText(UiUtils.translate(context, 'myProfile')),
          showBackButton: false,
        ),
        body: BlocListener<DeleteAccountCubit, DeleteAccountState>(
          listener: (context, state) {
            if (state is DeleteAccountProgress) {
              unawaited(Widgets.showLoader(context));
            }
            if (state is DeleteAccountFailure) {
              Widgets.hideLoder(context);
            }
            if (state is AccountDeleted) {
              Widgets.hideLoder(context);
              context.read<UserDetailsCubit>().clear();
              Navigator.pushReplacementNamed(
                context,
                Routes.login,
                arguments: {'popToCurrent': false},
              );
            }
          },
          child: CustomRefreshIndicator(
            onRefresh: () async {
              await context.read<FetchSystemSettingsCubit>().fetchSettings(
                    isAnonymous: GuestChecker.value,
                  );
              await context.read<GetApiKeysCubit>().fetch();
            },
            child: systemSettingsState is FetchSystemSettingsInProgress
                ? buildProfileLoadingShimmer()
                : SingleChildScrollView(
                    physics: Constant.scrollPhysics,
                    controller: profileScreenController,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: <Widget>[
                          // Profile Header
                          const SizedBox(height: 20),
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: context.color.tertiaryColor,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: context.color.tertiaryColor.withOpacity(0.2),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: profileImgWidget(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                CustomText(
                                  username.toUpperCase(),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: context.color.textColorDark,
                                ),
                                CustomText(
                                  email,
                                  fontSize: 14,
                                  color: context.color.textLightColor,
                                ),
                                if (isGuest == false) ...[
                                  const SizedBox(height: 12),
                                  _buildVerificationUI(
                                    context,
                                    verificationStatus,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Premium Actions
                          Row(
                            children: [
                              Expanded(
                                child: _actionCard(
                                  context,
                                  title: 'GALLERIA',
                                  subtitle: 'AI Creations',
                                  icon: Icons.collections_rounded,
                                  onTap: () => Navigator.pushNamed(context, Routes.historyTab),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _actionCard(
                                  context,
                                  title: 'MEMBERSHIP',
                                  subtitle: 'Active Plan',
                                  icon: Icons.workspace_premium_rounded,
                                  accent: true,
                                  onTap: () => _navigateToSubscriptions(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Menu Sections
                          // Menu Sections
                          _sectionHeader('ACCOUNT PREFERENCES'),
                          const SizedBox(height: 12),
                          _menuTile(
                            context,
                            title: 'Edit Profile Information',
                            icon: Icons.person_outline_rounded,
                            onTap: () => _navigateToEditProfile(context),
                          ),
                          _menuTile(
                            context,
                            title: 'Notification Settings',
                            icon: Icons.notifications_none_rounded,
                            onTap: () => Navigator.pushNamed(context, Routes.notificationPage),
                          ),
                          _menuTile(
                            context,
                            title: 'Dark Experience',
                            icon: Icons.dark_mode_outlined,
                            isSwitch: true,
                            onTap: () {},
                          ),

                          const SizedBox(height: 32),
                          _sectionHeader('SUPPORT & LEGAL'),
                          const SizedBox(height: 12),
                          _menuTile(
                            context,
                            title: 'Help & FAQ',
                            icon: Icons.help_outline_rounded,
                            onTap: () => Navigator.pushNamed(context, Routes.faqsScreen),
                          ),
                          _menuTile(
                            context,
                            title: 'Privacy Policy',
                            icon: Icons.security_outlined,
                            onTap: () => _navigateToLegal(context, 'privacyPolicy', Api.privacyPolicy),
                          ),
                          _menuTile(
                            context,
                            title: 'Terms of Service',
                            icon: Icons.description_outlined,
                            onTap: () => _navigateToLegal(context, 'termsConditions', Api.termsAndConditions),
                          ),
                          
                          if (Constant.isUpdateAvailable == true) ...[
                             const SizedBox(height: 12),
                             _menuTile(
                              context,
                              title: 'Update Available (${Constant.newVersionNumber})',
                              icon: Icons.system_update_rounded,
                              onTap: () async {
                                if (Platform.isIOS) {
                                  await launchUrl(Uri.parse(Constant.appstoreURLios));
                                } else if (Platform.isAndroid) {
                                  await launchUrl(Uri.parse(Constant.playstoreURLAndroid));
                                }
                              },
                            ),
                          ],

                          if (isGuest == false) ...[
                            const SizedBox(height: 32),
                            _sectionHeader('DANGER ZONE'),
                            const SizedBox(height: 12),
                            _menuTile(
                              context,
                              title: 'Delete Account',
                              icon: Icons.delete_forever_rounded,
                              onTap: () {
                                if (Constant.isDemoModeOn &&
                                    context.read<UserDetailsCubit>().state.user?.authId == Constant.demoFirebaseID) {
                                  HelperUtils.showSnackBarMessage(context, 'thisActionNotValidDemo'.translate(context));
                                  return;
                                }
                                deleteConfirmWidget(
                                  'deleteProfileMessageTitle'.translate(context),
                                  'deleteProfileMessageContent'.translate(context),
                                  true,
                                );
                              },
                            ),
                          ],

                          const SizedBox(height: 48),
                          if (isGuest == false)
                            _buildLogoutButton(context),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: logOutConfirmWidget,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 20),
            const SizedBox(width: 12),
            CustomText(
              'LOGOUT',
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.red.shade400,
              letterSpacing: 1.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: CustomText(
        title,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: context.color.tertiaryColor,
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool accent = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: accent ? context.color.tertiaryColor : context.color.secondaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: accent ? Colors.white : context.color.tertiaryColor,
              size: 28,
            ),
            const SizedBox(height: 16),
            CustomText(
              title,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: accent ? Colors.white : context.color.textColorDark,
              letterSpacing: 1,
            ),
            CustomText(
              subtitle,
              fontSize: 11,
              color: accent ? Colors.white.withOpacity(0.8) : context.color.textLightColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isSwitch = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.color.secondaryColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.color.tertiaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: context.color.tertiaryColor, size: 20),
        ),
        title: CustomText(
          title,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.color.textColorDark,
        ),
        trailing: isSwitch
            ? Switch.adaptive(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (v) {
                  // Theme toggle logic
                },
                activeColor: context.color.tertiaryColor,
              )
            : Icon(Icons.chevron_right_rounded, color: context.color.textLightColor, size: 20),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    context.read<GetUserDataCubit>().getUserData();
    HelperUtils.goToNextPage(
      Routes.editProfile,
      context,
      false,
      args: {'from': 'profile'},
    );
  }

  void _navigateToSubscriptions(BuildContext context) {
    GuestChecker.check(
      onNotGuest: () async {
        try {
          await context.read<GetApiKeysCubit>().fetch();
          if (context.read<GetApiKeysCubit>().state is GetApiKeysSuccess) {
            await Navigator.pushNamed(
              context,
              Routes.subscriptionPackageListRoute,
              arguments: {
                'isBankTransferEnabled': (context.read<GetApiKeysCubit>().state as GetApiKeysSuccess).bankTransferStatus == '1',
              },
            );
          }
        } catch (e) {
          log(e.toString());
        }
      },
    );
  }

  void _navigateToLegal(BuildContext context, String titleKey, String param) {
    Navigator.pushNamed(
      context,
      Routes.profileSettings,
      arguments: {
        'title': UiUtils.translate(context, titleKey),
        'param': param,
      },
    );
  }

  Widget buildProfileLoadingShimmer() {
    return SingleChildScrollView(
      physics: Constant.scrollPhysics,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomShimmer(height: MediaQuery.of(context).size.height * 0.13),
            const SizedBox(
              height: 16,
            ),
            CustomShimmer(
              height: MediaQuery.of(context).size.height,
            ),
            const SizedBox(
              height: 16,
            ),
            CustomShimmer(height: MediaQuery.of(context).size.height * 0.07),
          ],
        ),
      ),
    );
  }

  Widget dividerWithSpacing() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 1,
      color: context.color.borderColor.withOpacity(0.3),
    );
  }

  Widget updateTile(
    BuildContext context, {
    required String title,
    required String newVersion,
    required bool isUpdateAvailable,
    required String svgImagePath,
    required VoidCallback onTap,
    dynamic Function(dynamic value)? onTapSwitch,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: GestureDetector(
        onTap: () {
          if (isUpdateAvailable) {
            onTap.call();
          }
        },
        child: Row(
          children: [
            Container(
              width: 40.rw(context),
              height: 40.rh(context),
              decoration: BoxDecoration(
                color: context.color.tertiaryColor
                    .withOpacity(0.10000000149011612),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FittedBox(
                fit: BoxFit.none,
                child: isUpdateAvailable == false
                    ? const Icon(Icons.done)
                    : CustomImage(
                        imageUrl: svgImagePath,
                        color: context.color.tertiaryColor,
                      ),
              ),
            ),
            SizedBox(
              width: 25.rw(context),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  isUpdateAvailable == false
                      ? 'uptoDate'.translate(context)
                      : title,
                  fontWeight: FontWeight.w700,
                  color: context.color.textColorDark,
                ),
                if (isUpdateAvailable)
                  CustomText(
                    'v$newVersion',
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    color: context.color.textColorDark,
                    fontSize: context.font.xs,
                  ),
              ],
            ),
            if (isUpdateAvailable) ...[
              const Spacer(),
              Container(
                width: 32.rw(context),
                height: 32.rh(context),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: context.color.borderColor, width: 1.5),
                  color: context.color.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FittedBox(
                  fit: BoxFit.none,
                  child: CustomImage(
                    imageUrl: AppIcons.arrowRight,
                    matchTextDirection: true,
                    color: context.color.textColorDark,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget customTile(
    BuildContext context, {
    required String title,
    required String svgImagePath,
    required VoidCallback onTap,
    bool? isSwitchBox,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.color.tertiaryColor.withOpacity(0.15),
                        context.color.tertiaryColor.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomImage(
                    imageUrl: svgImagePath,
                    height: 20,
                    width: 20,
                    color: context.color.tertiaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomText(
                    title,
                    fontSize: context.font.md,
                    fontWeight: FontWeight.w600,
                    color: context.color.textColorDark,
                  ),
                ),
                if (isSwitchBox != true)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: context.color.borderColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: context.color.textColorDark.withOpacity(0.6),
                    ),
                  ),
                if (isSwitchBox ?? false)
                  BlocBuilder<AppThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      final isDark = context.read<AppThemeCubit>().isDarkMode;
                      return Switch(
                        value: isDark,
                        onChanged: (val) {
                          final newTheme =
                              isDark ? ThemeMode.light : ThemeMode.dark;
                          context.read<AppThemeCubit>().changeTheme(newTheme);
                        },
                        activeThumbColor: context.color.tertiaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void deleteConfirmWidget(String title, String desc, dynamic callDel) {
    UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        title: title,
        content: CustomText(
          desc,
          textAlign: TextAlign.center,
        ),
        acceptButtonName: 'deleteBtnLbl'.translate(context),
        acceptTextColor: context.color.buttonColor,
        cancelTextColor: context.color.textColorDark,
        svgImagePath: AppIcons.deleteIllustration,
        isAcceptContainesPush: true,
        onAccept: () async {
          final L = HiveUtils.getUserLoginType();
          Navigator.of(context).pop();
          if (callDel as bool? ?? false) {
            Future.delayed(
              const Duration(microseconds: 100),
              () async {
                unawaited(Widgets.showLoader(context));
                try {
                  // throw FirebaseAuthException(code: "requires-recent-login");
                  if (L == LoginType.phone &&
                      AppSettings.otpServiceProvider == 'firebase') {
                    await FirebaseAuth.instance.currentUser?.delete();
                  }
                  if (L == LoginType.apple || L == LoginType.google) {
                    await FirebaseAuth.instance.currentUser?.delete();
                  }

                  await context.read<DeleteAccountCubit>().deleteAccount(
                        context,
                      );
                  if (L == LoginType.email) {
                    Constant.interestedPropertyIds.clear();
                    context
                        .read<LikedPropertiesCubit>()
                        .state
                        .likedProperties
                        .clear();
                    context.read<LikedPropertiesCubit>().clear();
                    await context.read<LoadChatMessagesCubit>().close();
                  }
                  Widgets.hideLoder(context);
                  context.read<UserDetailsCubit>().clear();
                  await Navigator.pushReplacementNamed(
                    context,
                    Routes.login,
                    arguments: {'popToCurrent': true},
                  );
                } on Exception catch (e) {
                  Widgets.hideLoder(context);
                  if (e is FirebaseAuthException) {
                    if (e.code == 'requires-recent-login') {
                      await UiUtils.showBlurredDialoge(
                        context,
                        dialog: BlurredDialogBox(
                          title: 'Recent login required'.translate(context),
                          acceptTextColor: context.color.buttonColor,
                          showCancleButton: false,
                          content: CustomText(
                            'logoutAndLoginAgain'.translate(context),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  } else {
                    await UiUtils.showBlurredDialoge(
                      context,
                      dialog: BlurredDialogBox(
                        title: 'somethingWentWrng'.translate(context),
                        acceptTextColor: context.color.buttonColor,
                        showCancleButton: false,
                        content: CustomText(e.toString()),
                      ),
                    );
                  }
                }
              },
            );
          } else {
            await HiveUtils.logoutUser(
              context,
              onLogout: () {},
            );
          }
        },
      ),
    );
  }

  Widget profileImgWidget() {
    return GestureDetector(
      onTap: () {
        UiUtils.showFullScreenImage(
          context,
          provider: NetworkImage(
            context.read<UserDetailsCubit>().state.user?.profile ?? '',
          ),
        );
      },
      child: (context.watch<UserDetailsCubit>().state.user?.profile ?? '')
              .trim()
              .isEmpty
          ? buildDefaultPersonSVG(context)
          : CustomImage(
              imageUrl:
                  context.watch<UserDetailsCubit>().state.user?.profile ?? '',
              width: 80.rw(context),
              height: 80.rh(context),
              isCircular: true,
            ),
    );
  }

  Widget buildDefaultPersonSVG(BuildContext context) {
    return Container(
      width: 80.rw(context),
      height: 80.rh(context),
      color: context.color.tertiaryColor.withOpacity(0.1),
      child: FittedBox(
        fit: BoxFit.none,
        child: CustomImage(
          imageUrl: AppIcons.defaultPersonLogo,
          color: context.color.tertiaryColor,
          width: 32.rw(context),
          height: 32.rh(context),
        ),
      ),
    );
  }

  void shareApp() {
    try {
      if (Platform.isAndroid) {
        SharePlus.instance.share(
          ShareParams(
            text:
                '${Constant.appName}\n${Constant.playstoreURLAndroid}\n${'shareApp'.translate(context)}',
            subject: Constant.appName,
          ),
        );
      } else if (Platform.isIOS) {
        SharePlus.instance.share(
          ShareParams(
            text:
                '${Constant.appName}\n${Constant.appstoreURLios}\n${'shareApp'.translate(context)}',
            subject: Constant.appName,
          ),
        );
      }
    } on Exception catch (e) {
      HelperUtils.showSnackBarMessage(context, e.toString());
    }
  }

  Future<void> rateUs() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.openStoreListing();
    }
  }

  void logOutConfirmWidget() {
    UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        title: UiUtils.translate(context, 'confirmLogoutTitle'),
        onAccept: () async {
          try {
            final L = HiveUtils.getUserLoginType();
            if (L == LoginType.email) {
              Future.delayed(
                Duration.zero,
                () {
                  Constant.interestedPropertyIds.clear();
                  context.read<UserDetailsCubit>().clear();
                  context.read<LikedPropertiesCubit>().clear();
                  context.read<LoadChatMessagesCubit>().close();
                  HiveUtils.logoutUser(context, onLogout: () {});
                },
              );
            }
            if (L == LoginType.phone &&
                AppSettings.otpServiceProvider == 'twilio') {
              Future.delayed(
                Duration.zero,
                () {
                  Constant.interestedPropertyIds.clear();
                  context.read<UserDetailsCubit>().clear();
                  context.read<LikedPropertiesCubit>().clear();
                  context.read<LoadChatMessagesCubit>().close();
                  HiveUtils.logoutUser(context, onLogout: () {});
                },
              );
            }
            if (L == LoginType.phone &&
                AppSettings.otpServiceProvider == 'firebase') {
              Future.delayed(
                Duration.zero,
                () {
                  Constant.interestedPropertyIds.clear();
                  context.read<UserDetailsCubit>().clear();
                  context.read<LikedPropertiesCubit>().clear();
                  context.read<LoadChatMessagesCubit>().close();
                  HiveUtils.logoutUser(context, onLogout: () {});
                },
              );
            }
            if (L == LoginType.google || L == LoginType.apple) {
              Future.delayed(
                Duration.zero,
                () {
                  Constant.interestedPropertyIds.clear();
                  context.read<UserDetailsCubit>().clear();
                  context.read<LikedPropertiesCubit>().clear();
                  context.read<LoadChatMessagesCubit>().close();
                  HiveUtils.logoutUser(context, onLogout: () {});
                },
              );
              await gsis.GoogleSignIn.instance.signOut();
            }
          } on Exception catch (e) {
            log('Issue while logout is $e');
          }
        },
        cancelTextColor: context.color.textColorDark,
        svgImagePath: AppIcons.logoutIllustration,
        acceptTextColor: context.color.buttonColor,
        content: CustomText(
          UiUtils.translate(context, 'confirmLogOutMsg'),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildVerificationUI(BuildContext context, String status) {
    const verifyButtonPadding = EdgeInsetsDirectional.only(
      start: 4,
      end: 8,
      top: 2,
      bottom: 2,
    );

    // Cache context-dependent values
    final colorScheme = context.color;

    switch (status) {
      case 'initial':
        return _buildVerificationButton(
          onTap: () => _handleVerificationTap(context, 'initial'),
          padding: verifyButtonPadding,
          backgroundColor: colorScheme.tertiaryColor,
          child: _buildVerificationContent(
            icon: _buildAgentBadgeIcon(colorScheme.buttonColor),
            text: 'verifyNow'.translate(context),
            textColor: colorScheme.buttonColor,
          ),
        );

      case 'pending':
        return _buildVerificationContainer(
          padding: verifyButtonPadding,
          backgroundColor: Colors.orangeAccent.withOpacity(0.1),
          child: _buildVerificationContent(
            icon: Icon(
              Icons.access_time_filled_rounded,
              color: Colors.orangeAccent,
              size: 16.rh(context),
            ),
            text: 'verificationPending'.translate(context),
            textColor: Colors.orangeAccent,
            spacing: 2,
            leadingSpacing: 4,
          ),
        );

      case 'success':
        return _buildVerificationContainer(
          padding: verifyButtonPadding,
          backgroundColor: colorScheme.tertiaryColor.withOpacity(0.1),
          child: _buildVerificationContent(
            icon: _buildAgentBadgeIcon(colorScheme.tertiaryColor),
            text: 'verified'.translate(context),
            textColor: colorScheme.tertiaryColor,
            spacing: 2,
          ),
        );

      case 'failed':
        return _buildVerificationButton(
          onTap: () => _handleVerificationTap(context, 'failed'),
          padding: verifyButtonPadding,
          backgroundColor: colorScheme.error.withOpacity(0.1),
          child: _buildVerificationContent(
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Icon(
                Icons.cancel_rounded,
                color: colorScheme.error,
                size: 16.rh(context),
              ),
            ),
            text: 'formRejected'.translate(context),
            textColor: colorScheme.error,
            spacing: 2,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

// Helper method for tappable verification buttons
  Widget _buildVerificationButton({
    required VoidCallback onTap,
    required EdgeInsetsDirectional padding,
    required Color backgroundColor,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _buildVerificationContainer(
        padding: padding,
        backgroundColor: backgroundColor,
        child: child,
      ),
    );
  }

// Helper method for verification container styling
  Widget _buildVerificationContainer({
    required EdgeInsetsDirectional padding,
    required Color backgroundColor,
    required Widget child,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }

// Helper method for verification content layout
  Widget _buildVerificationContent({
    required Widget icon,
    required String text,
    required Color textColor,
    double spacing = 0,
    double leadingSpacing = 0,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingSpacing > 0) SizedBox(width: leadingSpacing),
        icon,
        if (spacing > 0) SizedBox(width: spacing),
        CustomText(
          text,
          fontWeight: FontWeight.bold,
          fontSize: context.font.xs,
          color: textColor,
        ),
      ],
    );
  }

// Helper method for agent badge icon
  Widget _buildAgentBadgeIcon(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: FittedBox(
        fit: BoxFit.none,
        child: CustomImage(
          imageUrl: AppIcons.agentBadge,
          height: 16.rh(context),
          width: 16.rw(context),
          color: color,
        ),
      ),
    );
  }

// Extracted and optimized verification tap handler
  Future<void> _handleVerificationTap(
    BuildContext context,
    String expectedStatus,
  ) async {
    try {
      final systemRepository = SystemRepository();
      final fetchSystemSettings = await systemRepository.fetchSystemSettings(
        isAnonymouse: false,
      );

      final currentStatus = fetchSystemSettings['data']['verification_status'];

      if (currentStatus == expectedStatus) {
        HelperUtils.goToNextPage(
          Routes.agentVerificationForm,
          context,
          false,
        );
      } else {
        await HelperUtils.showSnackBarMessage(
          context,
          'formAlreadySubmitted'.translate(context),
        );
      }
    } on Exception catch (_) {
      // Handle potential errors gracefully
      await HelperUtils.showSnackBarMessage(
        context,
        'errorOccurred'.translate(context),
      );
    }
  }
}
