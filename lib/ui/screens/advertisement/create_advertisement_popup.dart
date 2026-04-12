import 'package:flutter/material.dart';
import 'package:homiq/data/model/project_model.dart';
import 'package:homiq/data/model/property_model.dart';
import 'package:homiq/utils/extensions/extensions.dart';
import 'package:homiq/utils/extensions/lib/custom_text.dart';

class CreateAdvertisementPopup extends StatefulWidget {
  final PropertyModel property;
  final bool isProject;
  final ProjectModel? project;

  const CreateAdvertisementPopup({
    super.key,
    required this.property,
    this.isProject = false,
    this.project,
  });

  @override
  State<CreateAdvertisementPopup> createState() => _CreateAdvertisementPopupState();
}

class _CreateAdvertisementPopupState extends State<CreateAdvertisementPopup> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: CustomText('promoteListing'.translate(context)),
      content: const CustomText('This feature is coming soon.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: CustomText('closeBtnLbl'.translate(context)),
        ),
      ],
    );
  }
}
