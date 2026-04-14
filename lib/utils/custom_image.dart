import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homiq/utils/constant.dart';
import 'package:homiq/utils/ui_utils.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({
    this.imageUrl,
    this.icon,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
    this.color,
    super.key,
    this.cacheHeight,
    this.cacheWidth,
    this.isCircular = false,
    this.matchTextDirection = false,
    this.showFullScreenImage = false,
    this.placeholder,
    this.errorBuilder,
    this.colorFilter,
  });

  const CustomImage.circular({
    super.key,
    this.imageUrl,
    this.icon,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
    this.color,
    this.placeholder,
    this.errorBuilder,
    this.colorFilter,
    this.showFullScreenImage = false,
    this.isCircular = true,
    this.cacheHeight,
    this.cacheWidth,
    this.matchTextDirection = false,
  });

  final String? imageUrl;
  final FaIconData? icon;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final Color? color;
  final String? placeholder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final ColorFilter? colorFilter;
  final bool showFullScreenImage;
  final bool isCircular;
  final double? cacheHeight;
  final double? cacheWidth;
  final bool matchTextDirection;

  @override
  Widget build(BuildContext context) {
    // If an icon is provided, render it using FaIcon
    if (icon != null) {
      return FaIcon(icon, size: width ?? height, color: color);
    }

    final effectiveImageUrl = imageUrl ?? '';
    final errorImg = placeholder ?? '';
    var image = effectiveImageUrl.isEmpty ? errorImg : effectiveImageUrl;

    // If image is still empty after fallback, show a placeholder icon
    if (image.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircular ? null : BorderRadius.circular(12),
        ),
        child: Icon(Icons.image_outlined, size: (width ?? height ?? 24) * 0.5, color: color ?? Colors.grey),
      );
    }

    // Prepend base URL for relative network paths
    if (!image.startsWith('http') &&
        !image.startsWith('assets/') &&
        image.isNotEmpty) {
      image = '${Constant.baseUrl}/$image';
    }

    final isNetworked = image.startsWith('http');
    final isSvg = image.endsWith('.svg');

    final colorFilter = color != null
        ? ColorFilter.mode(color!, BlendMode.srcIn)
        : null;

    final errorWidget = errorImg.isEmpty 
        ? Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
            ),
            child: Icon(Icons.broken_image_outlined, size: (width ?? height ?? 24) * 0.5, color: Colors.grey),
          )
        : (errorImg.startsWith('http') 
            ? Image.network(errorImg, width: width, height: height, fit: fit) 
            : Image.asset(errorImg, width: width, height: height, fit: fit));

    return GestureDetector(
      onTap: showFullScreenImage && isNetworked
          ? () {
              UiUtils.showFullScreenImage(
                context,
                provider: CachedNetworkImageProvider(image),
              );
            }
          : null,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: isCircular
              ? BorderRadius.circular(99999)
              : BorderRadius.zero,
          child: switch ((isNetworked, isSvg)) {
            // asset image
            (false, false) => Image.asset(
              image,
              fit: fit,
              alignment: alignment,
              errorBuilder: (_, o, s) => errorWidget,
              matchTextDirection: matchTextDirection,
              cacheHeight: cacheHeight?.toInt() ?? 500,
              cacheWidth: cacheWidth?.toInt() ?? 500,
            ),
            // svg image
            (false, true) => SvgPicture.asset(
              image,
              fit: fit,
              width: width,
              height: height,
              colorFilter: colorFilter,
              alignment: alignment,
              matchTextDirection: matchTextDirection,
            ),
            // network image
            (true, false) => CachedNetworkImage(
              fit: fit,
              alignment: alignment,
              imageUrl: image,
              errorWidget: (_, s, o) => errorWidget,
              matchTextDirection: matchTextDirection,
              memCacheHeight: cacheHeight?.toInt() ?? 500,
              memCacheWidth: cacheWidth?.toInt() ?? 500,
            ),
            //
            (true, true) => SvgPicture.network(
              image,
              colorFilter: colorFilter,
              fit: fit,
              alignment: alignment,
              matchTextDirection: matchTextDirection,
            ),
          },
        ),
      ),
    );
  }
}
