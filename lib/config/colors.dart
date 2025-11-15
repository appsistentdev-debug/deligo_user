import 'package:flutter/material.dart';

Color mainColor = const Color(0xff00A302);
Color ratingCardColor = const Color(0xff7ac81e);
Color greyTextColor = const Color(0xff979ca7);
Color greyTextColor2 = const Color(0xff50555c);
Color greyTextColor3 = const Color(0xff7a7a7a);
Color cardColor = const Color(0xfff5f7f9);
Color blackColor = Colors.black;
Color darkBottomNavBarColor = Color(0xFF27292E);

Color disabledColor = const Color(0xffF4F7F9);
Color indicatorColor = const Color(0xFFDFF6E0);
Color unselectedItemColor = const Color(0xffc0c5c1);
Color selectedColor = const Color(0xFF434343);

Color orderGreen = const Color(0xff7AC81E);
Color orderGreenLight = const Color(0xffE9FFCE);
Color orderOrange = const Color(0xffF3AA1B);
Color orderOrangeLight = const Color(0xffFFEAC2);
Color orderBlack = const Color(0xff27292E);
Color orderBlackLight = const Color(0xffEFF1F6);

Color gradientColor1 = const Color(0xff7AC81E);
Color gradientColor2 = const Color(0xff509F12);

Color darkGradientColor1 = Colors.grey[800]!;
Color lightGradientColor1 = Colors.grey[300]!;
Color darkGradientColor2 = Colors.grey[700]!;
Color lightGradientColor2 = Colors.grey[100]!;

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}
