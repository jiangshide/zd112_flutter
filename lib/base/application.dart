import 'package:flutter/material.dart';

typedef void LocaleChangeCallback(Locale locale);

class Application{
  final List<String> supportedLanguages = ['en','zd'];

  Iterable<Locale> supportedLocales() => supportedLanguages.map((lang) => Locale(lang,''));

  LocaleChangeCallback onLocaleChanged;

  static final Application _application = Application._internal();

  factory Application(){
    return _application;
  }

  Application._internal();
}

Application application = Application();