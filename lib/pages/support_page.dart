import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/flavors.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:deligo/widgets/toaster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: const SupportStateful(),
      );
}

class SupportStateful extends StatefulWidget {
  const SupportStateful({super.key});

  @override
  State<SupportStateful> createState() => _SupportStatefulState();
}

class _SupportStatefulState extends State<SupportStateful> {
  final TextEditingController _supportController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is SupportLoading) {
          Loader.showLoader(context);
        } else {
          Loader.dismissLoader(context);
        }
        if (state is SupportLoaded) {
          Toaster.showToastTop(AppLocalization.instance
              .getLocalizationFor("support_has_been_submitted"));
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: RegularAppBar(
          title: AppLocalization.instance.getLocalizationFor("Support"),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    Center(
                      child: Image.asset(
                        isDark ? F.logoLight : F.logo,
                        height: 100,
                        width: 100,
                      ),
                    ),
                    const SizedBox(height: 80),
                    Text(
                      AppLocalization.instance
                          .getLocalizationFor("writeUsYourQueries"),
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalization.instance
                          .getLocalizationFor("askUsOrSuggest"),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    CustomTextField(
                      title: AppLocalization.instance
                          .getLocalizationFor("enterYourMessage"),
                      hintText: AppLocalization.instance
                          .getLocalizationFor("writeSomething"),
                      maxLines: 3,
                      controller: _supportController,
                    ),
                    const SizedBox(height: 20), // Add some space above button
                  ],
                ),
              ),
            ),
            // Button stays at bottom
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomButton(
                text: AppLocalization.instance
                    .getLocalizationFor("submitMessage"),
                onTap: () {
                  if (_supportController.text.trim().length < 10 ||
                      _supportController.text.trim().length > 140) {
                    Toaster.showToastTop(AppLocalization.instance
                        .getLocalizationFor("invalid_length_message"));
                  } else {
                    Helper.clearFocus(context);
                    BlocProvider.of<FetcherCubit>(context)
                        .initSupportSubmit(_supportController.text.trim());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _supportController.dispose();
    super.dispose();
  }
}
