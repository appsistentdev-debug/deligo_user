import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:deligo/bloc/auth_cubit.dart';
import 'package:deligo/config/app_config.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/utility/string_extensions.dart';
import 'package:deligo/widgets/confirm_dialog.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:deligo/widgets/toaster.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_verification_page.dart';

class AuthSignUpPage extends StatelessWidget {
  final RegisterData registerRequest;

  const AuthSignUpPage(this.registerRequest, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is RegisterLoading) {
            Loader.showLoader(context);
          } else {
            Loader.dismissLoader(context);
          }
          if (state is RegisterLoaded) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AuthVerificationPage(
                        state.authResponse.user.mobile_number)));
          } else if (state is RegisterError) {
            Toaster.showToastBottom(
                AppLocalization.instance.getLocalizationFor(state.messageKey));
            if (kDebugMode) {
              print("register_error: ${state.messageKey}");
            }
          }
        },
        child: SignUpUI(registerRequest),
      ),
    );
  }
}

class SignUpUI extends StatefulWidget {
  final RegisterData registerData;

  const SignUpUI(this.registerData, {super.key});

  @override
  State<SignUpUI> createState() => _SignUpUIState();
}

class _SignUpUIState extends State<SignUpUI> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  RegisterData get registerData => widget.registerData;
  late TextEditingController _nameController,
      _emailController,
      _phoneController,
      _countryController;
  String? _isoCode, _dialCode;

  void _init() {
    _nameController = TextEditingController(text: registerData.name);
    _emailController = TextEditingController(text: registerData.email);
    if (registerData.phoneNumberData != null) {
      _phoneController = TextEditingController(
          text: registerData.phoneNumberData!.phoneNumber);
      _countryController = TextEditingController(
          text: registerData.phoneNumberData!.countryText);
      _isoCode = registerData.phoneNumberData!.isoCode;
      _dialCode = registerData.phoneNumberData!.dialCode;
    } else {
      _phoneController = TextEditingController();
      _countryController = TextEditingController();
    }
  }

  @override
  void initState() {
    _init();
    _isoCode = "IN";
    _dialCode = '+91';
    _countryController.text = "India";
    if (AppConfig.isDemoMode && registerData.phoneNumberData == null) {
      _phoneController.text = "9898989898";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: RegularAppBar(
          title: AppLocalization.instance.getLocalizationFor("registerNow")),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: FadedSlideAnimation(
          beginOffset: const Offset(0, 0.3),
          endOffset: const Offset(0, 0),
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height,
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    AppLocalization.instance
                        .getLocalizationFor("NotRegisteredWithUs"),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Stack(
                  //   alignment: Alignment.topRight,
                  //   children: [
                  //     ClipOval(
                  //       child: Image.asset(
                  //         'assets/placeholder_profile.png',
                  //         height: 85,
                  //         width: 85,
                  //       ),
                  //     ),
                  //     CircleAvatar(
                  //       radius: 14,
                  //       backgroundColor: blackColor,
                  //       child: Icon(
                  //         Icons.photo_camera,
                  //         color: theme.scaffoldBackgroundColor,
                  //         size: 14,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 28),
                  CustomTextField(
                    controller: _nameController,
                    hintText: AppLocalization.instance
                        .getLocalizationFor("enterFullName"),
                    title:
                        AppLocalization.instance.getLocalizationFor("fullName"),
                    textInputType: TextInputType.name,
                    validator: (value) => _nameController.text.validateFullName,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hintText: AppLocalization.instance
                        .getLocalizationFor("enterPhoneNumber"),
                    title: AppLocalization.instance
                        .getLocalizationFor("phoneNumber"),
                    initialValue:
                        registerData.phoneNumberData!.phoneNumberNormalised,
                    textInputType: TextInputType.phone,
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: _emailController,
                    hintText: AppLocalization.instance
                        .getLocalizationFor("enterEmailAddress"),
                    title: AppLocalization.instance
                        .getLocalizationFor("emailAddress"),
                    textInputType: TextInputType.emailAddress,
                    validator: (value) => _emailController.text.validateEmail,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(bottom: 28.0, left: 16, right: 16, top: 8),
        child: CustomButton(
          onTap: () => _checkAndRegister(),
        ),
      ),
    );
  }

  Future<void> _checkAndRegister() async {
    if (_nameController.text.trim().length < 3) {
      Toaster.showToastCenter(
          AppLocalization.instance.getLocalizationFor("enter_name"));
      return;
    }
    if (_emailController.text.trim().isEmpty ||
        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(_emailController.text.trim())) {
      Toaster.showToastCenter(
          AppLocalization.instance.getLocalizationFor("enter_email"));
      return;
    }
    if (_isoCode == null || _isoCode!.isEmpty) {
      Toaster.showToastCenter(
          AppLocalization.instance.getLocalizationFor("choose_country"));
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      Toaster.showToastCenter(
          AppLocalization.instance.getLocalizationFor("enter_phone"));
      return;
    }
    ConfirmDialog.showConfirmation(
            context,
            Text("$_dialCode${_phoneController.text.trim()}"),
            Text(AppLocalization.instance.getLocalizationFor("alert_phone")),
            AppLocalization.instance.getLocalizationFor("no"),
            AppLocalization.instance.getLocalizationFor("yes"))
        .then((value) {
      if (value != null && value == true) {
        BlocProvider.of<AuthCubit>(context).initRegistration(
            _dialCode!,
            _phoneController.text.trim(),
            _nameController.text.trim(),
            _emailController.text.trim(),
            null,
            registerData.imageUrl);
      }
    });
  }
}
