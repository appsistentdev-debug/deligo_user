import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    this.image,
    required this.title,
    this.isCard = false,
    this.icon,
    this.onTap,
    this.bgColor,
    this.iconColor,
    this.subtitle,
    this.height,
    this.crossAxisAlignment,
    this.showBorder = true,
    this.trailing,
  });

  final IconData? icon;
  final String? image;
  final bool isCard;
  final String title;
  final VoidCallback? onTap;
  final Color? bgColor;
  final Color? iconColor;
  final String? subtitle;
  final double? height;
  final CrossAxisAlignment? crossAxisAlignment;
  final bool showBorder;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 10),
        decoration: showBorder
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isDark ? theme.disabledColor : Colors.grey.shade200),
              )
            : null,
        //height: height ?? 54,
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(2),
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: bgColor ?? theme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon!,
                  color: iconColor ?? theme.scaffoldBackgroundColor,
                  size: 20,
                ),
              ),
            if (image != null)
              Align(
                alignment: isCard ? Alignment.bottomCenter : Alignment.center,
                child: Image.asset(
                  image!,
                  width: isCard ? 40 : 32,
                ),
              ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.unselectedWidgetColor,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
