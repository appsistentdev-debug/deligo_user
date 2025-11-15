import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:flutter/material.dart';

class TncPage extends StatelessWidget {
  const TncPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: RegularAppBar(
          title:
              AppLocalization.instance.getLocalizationFor("termsConditions")),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20),
          Text(
            AppSettings.terms,
            style: theme.textTheme.titleSmall
                ?.copyWith(letterSpacing: 0.8, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
