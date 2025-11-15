// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:deligo/config/app_config.dart';
import 'package:deligo/network/remote_repository.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:flutter/material.dart';

class LanguageCubit extends Cubit<Locale> {
  String _languageCode = AppConfig.languageDefault;
  LanguageCubit() : super(const Locale(AppConfig.languageDefault));

  String get currentLangCode => _languageCode;

  void localeSelected(String value) {
    Helper.setHeadersBase("X-Localization", value);
    emit(Locale(value));
    _languageCode = value;
  }

  Future<void> getCurrentLanguage() async {
    String currLang = await LocalDataLayer().getCurrentLanguage();
    localeSelected(currLang);
  }

  Future<void> setCurrentLanguage(String langCode, bool save) async {
    if (save) {
      await LocalDataLayer().setCurrentLanguage(langCode);
      RemoteRepository().updateUser({
        "language": langCode,
      }).then((value) {
        if (value != null) LocalDataLayer().setUserMe(value);
      });
    }
    localeSelected(langCode);
  }
}
