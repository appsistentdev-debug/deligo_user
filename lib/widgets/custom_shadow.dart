import 'package:flutter/material.dart';

class CustomShadow extends StatelessWidget {
  final bool isDirectionUp;
  final double? height;
  const CustomShadow({super.key, this.isDirectionUp = false, this.height});

  @override
  Widget build(BuildContext context) => Container(
        height: height ?? 30,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColorDark.withValues(alpha: 0.1),
              Theme.of(context).primaryColorDark.withValues(alpha: 0.05),
              Colors.transparent,
              Colors.transparent,
            ],
            begin: isDirectionUp ? Alignment.bottomCenter : Alignment.topCenter,
            end: isDirectionUp ? Alignment.topCenter : Alignment.bottomCenter,
          ),
        ),
      );
}
