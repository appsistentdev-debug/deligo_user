// ignore_for_file: deprecated_member_use

import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:deligo/bloc/app_cubit.dart';
import 'package:deligo/bloc/language_cubit.dart';
import 'package:deligo/config/app_config.dart';
import 'package:deligo/config/colors.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectLanguagePage extends StatefulWidget {
  final bool fromRoot;

  const SelectLanguagePage([
    Key? key,
    this.fromRoot = false,
  ]) : super(key: key);

  @override
  SelectLanguagePageState createState() => SelectLanguagePageState();
}

class SelectLanguagePageState extends State<SelectLanguagePage> {
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: RegularAppBar(
        title: AppLocalization.instance.getLocalizationFor("selectLanguage"),
      ),
      body: FadedSlideAnimation(
        beginOffset: const Offset(0, 0.3),
        endOffset: const Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: BlocBuilder<LanguageCubit, Locale>(
                builder: (context, currentLocale) {
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: AppConfig.languagesSupported.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => setState(() => _selectedLanguage =
                          AppConfig.languagesSupported.keys.elementAt(index)),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedLanguage ==
                                    AppConfig.languagesSupported.keys
                                        .elementAt(index)
                                ? Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.4)
                                : greyTextColor.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: _selectedLanguage ==
                                  AppConfig.languagesSupported.keys
                                      .elementAt(index)
                              ? Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.2)
                              : Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: Text(
                          AppConfig.languagesSupported.values
                              .elementAt(index)
                              .name,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: _selectedLanguage ==
                                            AppConfig.languagesSupported.keys
                                                .elementAt(index)
                                        ? Theme.of(context).primaryColor
                                        : theme.primaryColorDark,
                                  ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(bottom: 28.0, left: 16, right: 16, top: 8),
        child: CustomButton(
            text: AppLocalization.instance.getLocalizationFor("update"),
            onTap: () {
              BlocProvider.of<LanguageCubit>(context)
                  .setCurrentLanguage(_selectedLanguage!, true);
              if (widget.fromRoot) {
                BlocProvider.of<AppCubit>(context).initApp();
              } else {
                Navigator.pop(context);
              }
            }),
      ),
    );
  }
}
