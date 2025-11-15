// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deligo/bloc/app_cubit.dart';
import 'package:deligo/bloc/auth_cubit.dart';
import 'package:deligo/config/app_config.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/toaster.dart';

class AuthVerificationPage extends StatelessWidget {
  final String phoneNumber;
  final GlobalKey<VerificationUiState> vUiStateKey = GlobalKey();

  AuthVerificationPage(this.phoneNumber, {super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => AuthCubit(),
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is VerificationLoading) {
              Loader.showLoader(context);
            } else {
              Loader.dismissLoader(context);
            }
            if (state is VerificationSentLoaded) {
              vUiStateKey.currentState?._initTimer();
              Toaster.showToastBottom(
                  AppLocalization.instance.getLocalizationFor("code_sent"));
              if (AppConfig.isDemoMode && phoneNumber.contains("9898989898")) {
                BlocProvider.of<AuthCubit>(context).verifyOtp("123456");
              }
            } else if (state is VerificationVerifyingLoaded) {
              Navigator.pop(context);
              BlocProvider.of<AppCubit>(context).initAuthenticated();
            } else if (state is VerificationError) {
              Toaster.showToastBottom(AppLocalization.instance
                  .getLocalizationFor(state.messageKey));
              // if (state.messageKey == "something_wrong" ||
              //     state.messageKey == "role_exists") {
              //   Navigator.of(context).pop();
              // }
            }
          },
          child: VerificationUi(phoneNumber, key: vUiStateKey),
        ),
      );
}

class VerificationUi extends StatefulWidget {
  final String phoneNumber;
  const VerificationUi(this.phoneNumber, {super.key});

  @override
  State<VerificationUi> createState() => VerificationUiState();
}

class VerificationUiState extends State<VerificationUi> {
  Timer? _timer;
  int _timeLeft = 60;

  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthCubit>(context).initAuthentication(widget.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: RegularAppBar(
        title: AppLocalization.instance.getLocalizationFor("verification"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: FadedSlideAnimation(
          beginOffset: const Offset(0.0, 0.3),
          endOffset: Offset.zero,
          slideCurve: Curves.linearToEaseOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                AppLocalization.instance
                    .getLocalizationFor("enterVerificationCodeSent"),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 28),
              CustomTextField(
                controller: _otpController,
                title: AppLocalization.instance
                    .getLocalizationFor("verification_code"),
                textInputType: TextInputType.number,
                hintText:
                    AppLocalization.instance.getLocalizationFor("enterOtp"),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "0:${_timeLeft.toString().padLeft(2, '0')} ${AppLocalization.instance.getLocalizationFor("secLeft")}",
                    style: theme.textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: _timeLeft == 0 ? () => _initTimer() : null,
                    child: Text(
                      AppLocalization.instance.getLocalizationFor("resend"),
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _timeLeft == 0
                            ? theme.primaryColor
                            : theme.hintColor,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 50),
              CustomButton(
                text: AppLocalization.instance.getLocalizationFor("submit"),
                onTap: () {
                  if (_otpController.text.trim().isEmpty) {
                    Toaster.showToastCenter(AppLocalization.instance
                        .getLocalizationFor("otp_invalid"));
                    return;
                  }
                  BlocProvider.of<AuthCubit>(context)
                      .verifyOtp(_otpController.text.trim());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initTimer() {
    _timeLeft = 60;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_timeLeft == 0) {
          setState(() => timer.cancel());
        } else {
          setState(() => _timeLeft--);
        }
      },
    );
  }
}
