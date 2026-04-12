import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';
import 'package:homiq/data/model/subscription_pacakage_model.dart';
import 'package:homiq/data/repositories/subscription_repository.dart';
import 'package:homiq/exports/main_export.dart';

class SubscriptionPackageTile extends StatefulWidget {
  const SubscriptionPackageTile({
    required this.onTap,
    required this.package,
    required this.packageFeatures,
    super.key,
  });

  final SubscriptionPackageModel package;
  final List<AllFeature> packageFeatures;
  final VoidCallback onTap;

  @override
  State<SubscriptionPackageTile> createState() =>
      _SubscriptionPackageTileState();
}

class _SubscriptionPackageTileState extends State<SubscriptionPackageTile> {
  MultipartFile? _bankReceiptFile;

  @override
  Widget build(BuildContext context) {
    final Color tierColor = widget.package.price > 500
        ? const Color(0xFFFFD700)
        : (widget.package.price > 0
              ? const Color(0xFFC0C0C0)
              : context.color.tertiaryColor);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: tierColor.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: tierColor.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          buildPackageTitle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                packageFeaturesAndValidity(),
                const SizedBox(height: 20),
                buildPriceAndSubscribe(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getDuration({required int duration, required BuildContext context}) {
    final days = duration ~/ 24;
    return '$days';
  }

  Widget buildPriceAndSubscribe() {
    final isUnderReview = widget.package.packageStatus == 'review';
    final isRejected = widget.package.packageStatus == 'rejected';

    final Color tierColor = widget.package.price > 500
        ? const Color(0xFFFFD700) // Gold
        : (widget.package.price > 0
              ? const Color(0xFFC0C0C0)
              : Colors.tealAccent);

    return Column(
      children: [
        if (isUnderReview) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.history_toggle_off_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                CustomText(
                  'Verification Pending'.toUpperCase(),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.orange,
                  letterSpacing: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.color.primaryColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    widget.package.price == 0
                        ? 'FREE'
                        : '${Constant.currencySymbol}${widget.package.price}',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: context.color.textColorDark,
                  ),
                  CustomText(
                    'VALIDITY: ${widget.package.duration} DAYS',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: context.color.textLightColor,
                    letterSpacing: 1,
                  ),
                ],
              ),
              const Spacer(),
              if (isUnderReview)
                _smallButton(
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.transactionHistory),
                  label: 'VIEW STATUS',
                  color: context.color.tertiaryColor,
                )
              else if (isRejected)
                _smallButton(
                  onTap: () => _handleReupload(),
                  label: 'RE-UPLOAD',
                  color: Colors.red,
                )
              else
                _smallButton(
                  onTap: widget.onTap,
                  label: 'ACTIVATE',
                  color: tierColor,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _smallButton({
    required VoidCallback onTap,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: CustomText(
          label,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }

  void _handleReupload() {
    _pickAndUploadReceipt(widget.package.paymentTransactionId ?? '');
  }

  Widget buildPackageTitle() {
    final tierColor = widget.package.price > 500
        ? const Color(0xFFFFD700)
        : (widget.package.price > 0
              ? const Color(0xFFC0C0C0)
              : context.color.tertiaryColor);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.color.primaryColor.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tierColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: tierColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  widget.package.translatedName ??
                      widget.package.name.toUpperCase(),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: context.color.textColorDark,
                  letterSpacing: 1,
                ),
                CustomText(
                  'VIP DESIGN PASS',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: tierColor,
                  letterSpacing: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget packageFeaturesAndValidity() {
    return Column(
      children: [
        buildValidity(
          duration: widget.package.duration.toString(),
        ),
        const SizedBox(height: 18),
        buildPackageFeatures(
          packageFeatures: widget.packageFeatures,
          package: widget.package,
        ),
      ],
    );
  }

  Widget buildValidity({required String duration}) {
    final packageDuration = getDuration(
      duration: int.parse(duration),
      context: context,
    );
    return Row(
      children: [
        CustomImage(
          imageUrl: AppIcons.featureAvailable,
          height: 20.rh(context),
          width: 20.rw(context),
        ),
        const SizedBox(width: 8),
        CustomText(
          '${'validUntil'.translate(context)} $packageDuration ${packageDuration == '1' ? 'day'.translate(context) : 'days'.translate(context)}',
          fontSize: context.font.xs,
          color: context.color.textColorDark,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  Widget buildPackageFeatures({
    required List<AllFeature> packageFeatures,
    required SubscriptionPackageModel package,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: packageFeatures.length,
      itemBuilder: (context, index) {
        final allFeatures = packageFeatures[index];
        final isAvailable = package.features.any(
          (element) => element.id == allFeatures.id,
        );

        final includedFeatures = package.features
            .where((element) => element.id == allFeatures.id)
            .toList();

        var getLimit = '';
        if (includedFeatures.isNotEmpty) {
          if (includedFeatures[0].limit?.toString() != '0') {
            getLimit =
                includedFeatures[0].limit?.toString() ??
                includedFeatures[0].limitType.toString();
          } else {
            getLimit = includedFeatures[0].limitType.name.translate(context);
          }
        }

        return Row(
          children: [
            Icon(
              isAvailable
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_off_rounded,
              size: 18,
              color: isAvailable
                  ? context.color.tertiaryColor
                  : context.color.textLightColor.withOpacity(0.5),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomText(
                allFeatures.translatedName ?? allFeatures.name,
                fontSize: 13,
                color: isAvailable
                    ? context.color.textColorDark
                    : context.color.textLightColor,
                fontWeight: isAvailable ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (getLimit != '')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.color.tertiaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: CustomText(
                  getLimit.toUpperCase(),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: context.color.tertiaryColor,
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadReceipt(String transactionId) async {
    final filePickerResult = await fp.FilePicker.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: [
        'jpeg', 'png', 'jpg', 'pdf', 'doc', 'docx',
      ],
    );
    if (filePickerResult != null) {
      _bankReceiptFile = await MultipartFile.fromFile(
        filePickerResult.files.first.path!,
        filename: filePickerResult.files.first.path!.split('/').last,
      );
    }
    if (_bankReceiptFile == null) {
      await HelperUtils.showSnackBarMessage(
        context,
        'pleaseUploadReceipt'.translate(context),
      );
      return;
    }
    try {
      final result = await SubscriptionRepository().uploadBankReceiptFile(
        paymentTransactionId: transactionId,
        file: _bankReceiptFile!,
      );
      if (result['error'] == false) {
        unawaited(
          HelperUtils.showSnackBarMessage(
            context,
            'receiptUploaded'.translate(context),
          ),
        );
        await context
            .read<FetchSubscriptionPackagesCubit>()
            .fetchPackages();
      } else {
        await HelperUtils.showSnackBarMessage(
          context,
          result['message'].toString(),
        );
      }
    } on Exception catch (e) {
      await HelperUtils.showSnackBarMessage(
        context,
        e.toString(),
      );
    }
  }

  Widget buildUploadReceiptButton({
    required String transactionId,
  }) {
    return Flexible(
      child: UiUtils.buildButton(
        context,
        height: 32.rh(context),
        autoWidth: true,
        onPressed: () => _pickAndUploadReceipt(transactionId),
        buttonTitle: 'reUploadReceipt'.translate(context),
      ),
    );
  }
}

class MySeparator extends StatelessWidget {
  const MySeparator({
    super.key,
    this.height = 1,
    this.color = Colors.grey,
    this.isShimmer = false,
  });
  final double height;
  final Color color;
  final bool isShimmer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 10.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: isShimmer
                  ? CustomShimmer(
                      height: dashHeight,
                      width: dashWidth,
                      borderRadius: 0,
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(color: color),
                    ),
            );
          }),
        );
      },
    );
  }
}
