import 'package:flutter/material.dart';

import 'colors.dart';

Color pc = mainColor;
Color pcDark = mainColor;

ThemeData appTheme = ThemeData(
  fontFamily: 'ProductSans',
  scaffoldBackgroundColor: Colors.white,
  primaryColor: pc,
  primaryColorDark: blackColor,
  cardColor: cardColor,
  hintColor: greyTextColor,
  disabledColor: disabledColor,

  inputDecorationTheme: InputDecorationTheme(
    focusColor: pc,
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: pc,
    selectionColor: pc.withValues(alpha: 0.3),
    selectionHandleColor: pc,
  ),

  progressIndicatorTheme: ProgressIndicatorThemeData(color: pc),

  ///bottom bar theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: mainColor,
    backgroundColor: Colors.transparent,
    selectedLabelStyle: TextStyle(
      color: blackColor,
      fontSize: 10,
    ),
    unselectedLabelStyle: const TextStyle(
      fontSize: 10,
    ),
    unselectedItemColor: unselectedItemColor,
  ),

  ///appBar theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      fontFamily: 'ProductSans',
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),

  ///text theme
  textTheme: const TextTheme(
    headlineSmall: TextStyle(fontWeight: FontWeight.bold),
  ).apply(bodyColor: Colors.black),

  ///checkbox theme
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return mainColor; // Color when checkbox is checked
        }
        return Colors.white; // Color when checkbox is unchecked
      },
    ),
    checkColor: WidgetStateProperty.all(Colors.white), // Color of the checkmark
    // Add other properties as needed, e.g., overlayColor, splashRadius
  ),

  ///radio theme
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return mainColor; // Color when the radio button is selected
        }
        return Colors.black; // Default color for the radio button
      },
    ),
  ),
  tabBarTheme: TabBarThemeData(indicatorColor: indicatorColor),
);

Widget timePickerBuilder(ThemeData theme, Widget child) => Theme(
      data: theme.copyWith(
        colorScheme: ColorScheme.light(
          primary: theme.primaryColor,
          onPrimary: Colors.white,
          onSurface: Colors.black,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            textStyle: theme.textTheme.titleMedium,
          ),
        ),
        timePickerTheme: TimePickerThemeData(
          dayPeriodColor: theme.primaryColor.withAlpha(128),
          helpTextStyle: theme.textTheme.titleMedium,
        ),
      ),
      child: child,
    );

ThemeData darkAppTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Color(0xFF0F1012),
  primaryColor: pcDark,
  primaryColorDark: Color(0xFFF5F7F9),
  cardColor: Color(0xff1e1e1e),
  hintColor: greyTextColor,
  disabledColor: Color(0xFF4F5156),

  inputDecorationTheme: InputDecorationTheme(
    focusColor: pcDark,
    filled: true,
    fillColor: Color(0xff1e1e1e),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFF3E4044)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFF3E4044)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: pcDark),
    ),
    hintStyle: TextStyle(color: Color(0xFF8E8E93)),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: pcDark,
    selectionColor: pcDark.withValues(alpha: 0.3),
    selectionHandleColor: pcDark,
  ),

  progressIndicatorTheme: ProgressIndicatorThemeData(color: pcDark),

  ///bottom bar theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: mainColor,
    backgroundColor: Color(0xFF27292E),
    selectedLabelStyle: TextStyle(
      color: blackColor,
      fontSize: 10,
    ),
    unselectedLabelStyle: const TextStyle(
      fontSize: 10,
    ),
    unselectedItemColor: Color(0xFF4F5156),
  ),

  ///appBar theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      fontFamily: 'ProductSans',
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),

  ///text theme
  textTheme: ThemeData.dark()
      .textTheme
      .copyWith(
        headlineSmall: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'ProductSans',
        ),
      )
      .apply(
        bodyColor: Color(0xFFF5F7F9),
        displayColor: Colors.white,
      ),

  ///checkbox theme
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return mainColor; // Color when checkbox is checked
        }
        return Colors.white; // Color when checkbox is unchecked
      },
    ),
    checkColor: WidgetStateProperty.all(Colors.white), // Color of the checkmark
    // Add other properties as needed, e.g., overlayColor, splashRadius
  ),

  ///radio theme
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return mainColor; // Color when the radio button is selected
        }
        return Colors.black; // Default color for the radio button
      },
    ),
  ),
  tabBarTheme: TabBarThemeData(indicatorColor: indicatorColor),
);
