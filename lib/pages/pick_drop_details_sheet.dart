import 'package:deligo/config/colors.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/widgets/toaster.dart';
import 'package:flutter/material.dart';

class PickDropDetailsSheet extends StatefulWidget {
  final String type; // ["from", "to"]
  final String address;
  final Map<String, String> values;
  const PickDropDetailsSheet({
    super.key,
    required this.type,
    required this.address,
    required this.values,
  });

  @override
  State<PickDropDetailsSheet> createState() => _PickDropDetailsSheetState();
}

class _PickDropDetailsSheetState extends State<PickDropDetailsSheet> {
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    if (widget.values["landmark_${widget.type}"] != null) {
      _landmarkController.text = widget.values["landmark_${widget.type}"]!;
    }
    if (widget.values["name_${widget.type}"] != null) {
      _nameController.text = widget.values["name_${widget.type}"]!;
    }
    if (widget.values["phone_${widget.type}"] != null) {
      _phoneController.text = widget.values["phone_${widget.type}"]!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: theme.scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 14.0,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: theme.primaryColor,
                    child: Icon(
                      Icons.location_on,
                      size: 13,
                      color: theme.scaffoldBackgroundColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      widget.address,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: theme.scaffoldBackgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Divider(
                //   height: 6,
                //   thickness: 6,
                //   color: theme.colorScheme.surface,
                // ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomTextField(
                    hintText: AppLocalization.instance
                        .getLocalizationFor("select_landmark"),
                    controller: _landmarkController,
                    textInputType: TextInputType.text,
                    bgColor: isDark ? darkBottomNavBarColor : theme.cardColor,
                    prefixIcon: Icon(
                      Icons.stars_sharp,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomTextField(
                    hintText: AppLocalization.instance
                        .getLocalizationFor("hint_name_${widget.type}"),
                    controller: _nameController,
                    textInputType: TextInputType.name,
                    bgColor: isDark ? darkBottomNavBarColor : theme.cardColor,
                    prefixIcon: Icon(
                      Icons.person,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomTextField(
                    hintText: AppLocalization.instance
                        .getLocalizationFor("hint_phone_${widget.type}"),
                    controller: _phoneController,
                    bgColor: isDark ? darkBottomNavBarColor : theme.cardColor,
                    textInputType: TextInputType.phone,
                    prefixIcon: Icon(
                      Icons.call,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    text: AppLocalization.instance.getLocalizationFor("next"),
                    onTap: () {
                      if (_nameController.text.trim().isEmpty) {
                        Toaster.showToastCenter(AppLocalization.instance
                            .getLocalizationFor("select_name_${widget.type}"));
                        return;
                      }
                      if (_phoneController.text.trim().isEmpty) {
                        Toaster.showToastCenter(AppLocalization.instance
                            .getLocalizationFor("select_phone_${widget.type}"));
                        return;
                      }
                      Navigator.pop(context, {
                        "landmark_${widget.type}":
                            _landmarkController.text.trim(),
                        "name_${widget.type}": _nameController.text.trim(),
                        "phone_${widget.type}": _phoneController.text.trim(),
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _landmarkController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
