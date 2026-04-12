import 'package:flutter/material.dart';
import 'package:homiq/data/model/project_model.dart';
import 'package:homiq/utils/custom_image.dart';
import 'package:homiq/utils/responsive_size.dart';
import 'package:homiq/utils/ui_utils.dart';

class ProjectGallery extends StatelessWidget {
  final List<ProjectGalleryModel>? gallary;
  final VoidCallback onShowGoogleMap;

  const ProjectGallery({
    super.key,
    required this.gallary,
    required this.onShowGoogleMap,
  });

  @override
  Widget build(BuildContext context) {
    if (gallary == null || gallary!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gallery',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (gallary!.length > 3)
              TextButton(
                onPressed: () {
                  UiUtils.imageGallaryView(
                    context,
                    images: gallary!.map((e) => e.type).toList(),
                    initalIndex: 0,
                  );
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100.rh(context),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: gallary!.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  UiUtils.imageGallaryView(
                    context,
                    images: gallary!.map((e) => e.type).toList(),
                    initalIndex: index,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomImage(
                    imageUrl: gallary![index].type,
                    width: 100.rw(context),
                    height: 100.rh(context),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
