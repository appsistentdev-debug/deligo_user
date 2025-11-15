// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:ndialog/ndialog.dart';

class Loader {
  static bool _isLoaderShowing = false;
  static ProgressDialog? _progressDialog;

  static Widget loadingWidget(
          {required BuildContext context, String? message}) =>
      Align(
        alignment: Alignment.center,
        child: SizedBox(
          height: 260,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 24.0,
                  width: 24.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                ),
              ),
              Text(
                message != null && message.isNotEmpty
                    ? message
                    : AppLocalization.instance.getLocalizationFor("loading"),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 17),
              ),
            ],
          ),
        ),
      );

  static void showLoader(BuildContext context) {
    if (!Loader._isLoaderShowing) {
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (BuildContext context) =>
            Center(child: Loader.circularProgressIndicatorPrimary(context)),
      );
      Loader._isLoaderShowing = true;
    }
  }

  static void dismissLoader(BuildContext context) {
    if (Loader._isLoaderShowing) {
      Navigator.of(context).pop();
      Loader._isLoaderShowing = false;
    }
  }

  static void showProgress(
      BuildContext context, String progressTitleText, String progressBodyText) {
    if (_progressDialog == null) {
      _progressDialog = ProgressDialog(context,
          dismissable: false,
          title: Text(
            progressTitleText,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontSize: 17, color: Colors.black),
          ),
          message: Text(
            progressBodyText,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontSize: 14, color: Colors.grey),
          ));
    } else {
      _progressDialog!.setTitle(Text(
        progressTitleText,
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(fontSize: 17, color: Colors.black),
      ));
      _progressDialog!.setMessage(Text(
        progressBodyText,
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(fontSize: 14, color: Colors.grey),
      ));
    }
    _progressDialog!.show();
  }

  static void dismissProgress() {
    if (_progressDialog != null) {
      _progressDialog!.dismiss();
      _progressDialog = null;
    }
  }

  static Center circularProgressIndicatorPrimary(BuildContext context) =>
      Center(
          child: CircularProgressIndicator(
        valueColor:
            AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
      ));

  static Center circularProgressIndicatorWhite() => const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ));

  static Center circularProgressIndicatorDefault() =>
      const Center(child: CircularProgressIndicator());
}
