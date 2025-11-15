import 'package:deligo/config/colors.dart';
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double dashWidth;
  final double height;
  final Color color;
  final bool withoutPadding;

  const CustomDivider({
    super.key,
    this.height = 1,
    this.color = Colors.black12,
    this.dashWidth = 4.0,
    this.withoutPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: withoutPadding ? null : const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final boxWidth = constraints.constrainWidth();
          final dashHeight = height;
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(
              dashCount,
              (_) => SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: isDark ? darkBottomNavBarColor : color),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
