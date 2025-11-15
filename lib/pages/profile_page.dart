import 'dart:io';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/models/user_data.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/config/assets.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/utility/picker.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:deligo/widgets/toaster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: const ProfileStateful(),
      );
}

class ProfileStateful extends StatefulWidget {
  const ProfileStateful({super.key});

  @override
  State<ProfileStateful> createState() => _ProfileStatefulState();
}

class _ProfileStatefulState extends State<ProfileStateful> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late FetcherCubit _fetcherCubit;
  bool wasUpdating = false;
  UserData? user;
  File? _filePicked;

  @override
  void initState() {
    _fetcherCubit = BlocProvider.of<FetcherCubit>(context);
    super.initState();
    _fetcherCubit.initGetUserMe(true);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is UserMeUpdating) {
          Loader.showLoader(context);
        } else {
          Loader.dismissLoader(context);
        }

        if (state is UserMeLoaded) {
          if (wasUpdating) {
            Navigator.pop(context);
          } else {
            wasUpdating = false;
            setState(() {
              user = state.userMe;
              _nameController.text = user?.name ?? "";
              _phoneController.text = user?.mobile_number ?? "";
              _emailController.text = user?.email ?? "";
            });
          }
        }

        if (state is UserMeError) {
          wasUpdating = false;
          Toaster.showToastCenter(
              AppLocalization.instance.getLocalizationFor("something_wrong"));
        }
      },
      child: Scaffold(
        appBar: RegularAppBar(
            title: AppLocalization.instance.getLocalizationFor("my_profile")),
        body: Container(
          height: mediaQuery.size.height -
              kToolbarHeight -
              mediaQuery.viewPadding.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      // Text(
                      //   AppLocalization.instance.getLocalizationFor("profile"),
                      //   style: theme.textTheme.titleLarge?.copyWith(
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      // const SizedBox(height: 6),
                      // Text(
                      //   AppLocalization.instance
                      //       .getLocalizationFor("everythingAboutYou"),
                      //   style: theme.textTheme.bodyMedium?.copyWith(
                      //     color: theme.unselectedWidgetColor,
                      //   ),
                      // ),
                      // const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () => Picker()
                            .pickImageFile(
                              context: context,
                              pickerSource: PickerSource.ask,
                              cropConfig: CropConfig.square,
                            )
                            .then(
                              (File? pickedFile) =>
                                  setState(() => _filePicked = pickedFile),
                            ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _filePicked == null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12.5),
                                    child: CachedImage(
                                      imageUrl: user?.imageUrl,
                                      height: 100,
                                      width: 100,
                                      imagePlaceholder:
                                          Assets.assetsPlaceholderProfile,
                                      //fit: BoxFit.fill,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12.5),
                                    child: Image.file(
                                      _filePicked!,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                            PositionedDirectional(
                              end: -16,
                              top: 16,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: theme.primaryColor,
                                foregroundColor: theme.scaffoldBackgroundColor,
                                child: const Icon(Icons.camera_alt, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      CustomTextField(
                        title: AppLocalization.instance
                            .getLocalizationFor("fullName"),
                        controller: _nameController,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        title: AppLocalization.instance
                            .getLocalizationFor("phoneNumber"),
                        controller: _phoneController,
                        readOnly: true,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        title: AppLocalization.instance
                            .getLocalizationFor("emailAddress"),
                        controller: _emailController,
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ),
              CustomButton(
                text: AppLocalization.instance.getLocalizationFor("update"),
                onTap: () {
                  Helper.clearFocus(context);
                  if (_nameController.text.trim().isEmpty) {
                    Toaster.showToastCenter(
                        context.getLocalizationFor("enter_profile_name"));
                    return;
                  }
                  wasUpdating = true;
                  _fetcherCubit.initUpdateUserMe(
                      _nameController.text.trim(), _filePicked);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
