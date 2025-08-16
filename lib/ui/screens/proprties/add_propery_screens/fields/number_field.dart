import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:homiq/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:homiq/ui/screens/widgets/custom_text_form_field.dart';
import 'package:homiq/utils/Extensions/extensions.dart';
import 'package:homiq/utils/custom_image.dart';
import 'package:homiq/utils/extensions/lib/custom_text.dart';
import 'package:homiq/utils/responsive_size.dart';

class CustomNumberField extends CustomField<dynamic> {
  @override
  String type = 'number';
  TextEditingController? controller;
  @override
  void init() {
    id = data['id'];
    var initialValue = '';
    if (data['value'] != null && data['value'] != 'null') {
      initialValue = "${data['value']}";
    }

    controller = TextEditingController(text: initialValue);
    super.init();
  }

  @override
  String? backValue() {
    return controller?.text;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget render(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                width: 32.rw(context),
                height: 32.rh(context),
                decoration: BoxDecoration(
                  color: context.color.tertiaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomImage(
                  imageUrl: data['image']?.toString() ?? '',
                ),
              ),
              SizedBox(width: 8.rw(context)),
              CustomText(
                data['translated_name']?.toString() ??
                    data['name']?.toString() ??
                    '',
                fontWeight: FontWeight.w400,
                fontSize: context.font.sm,
                color: context.color.textColorDark,
              ),
              if (data['is_required'] == 1) ...[
                const SizedBox(width: 4),
                CustomText('*', color: context.color.error),
              ],
            ],
          ),
          SizedBox(height: 8.rh(context)),
          CustomTextFormField(
            hintText: 'addNumerical'.translate(context),
            action: TextInputAction.next,
            validator: CustomTextFieldValidator.nullCheck,
            formaters: [
              FilteringTextInputFormatter.allow(
                RegExp('[0-9]'),
              ),
            ],
            keyboard: TextInputType.number,
            controller: controller,
            onChange: (value) {
              // AbstractField.fieldsData.addAll({widget.id: value});
            },
          ),
        ],
      ),
    );
  }
}
