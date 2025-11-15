import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  /// pass title only if required to display
  final String? title;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final Color? bgColor;
  final bool showBorder;
  final bool readOnly;
  final bool restrictHeight;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final FormFieldValidator<String>? validator;
  final TextCapitalization textCapitalization;
  final TextAlignVertical? textAlignVertical;
  final FocusNode? focusNode;
  final Function(String query)? onChanged;

  const CustomTextField({
    super.key,
    this.title,
    this.hintText,
    this.initialValue,
    this.controller,
    this.textInputType,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines,
    this.bgColor,
    this.onTap,
    this.showBorder = true,
    this.readOnly = false,
    this.restrictHeight = false,
    this.margin = EdgeInsets.zero,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.textAlignVertical,
    this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style:
                  theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            height: restrictHeight ? 48 : null,
            child: TextFormField(
              focusNode: focusNode,
              onChanged: onChanged,
              textAlignVertical: textAlignVertical,
              keyboardType: textInputType,
              controller: controller,
              initialValue: initialValue,
              style: theme.textTheme.bodyLarge,
              maxLines: maxLines,
              onTap: onTap,
              readOnly: readOnly,
              validator: validator,
              textCapitalization: textCapitalization,
              decoration: InputDecoration(
                prefixIcon: prefixIcon,
                contentPadding: EdgeInsets.all(16),
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: bgColor ?? theme.cardColor,
                isDense: true,
                border: _getBorder(theme.hintColor),
                enabledBorder: _getBorder(theme.hintColor),
                focusedBorder: _getBorder(theme.primaryColor),
                hintText: hintText,
                hintStyle:
                    theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
              ),
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
          ),
        ],
      ),
    );
  }

  InputBorder _getBorder(Color color) {
    if (showBorder) {
      return OutlineInputBorder(
        borderSide: BorderSide(color: color.withValues(alpha: 0.3), width: 0.5),
        borderRadius: BorderRadius.circular(10),
      );
    } else {
      return InputBorder.none;
    }
  }
}
