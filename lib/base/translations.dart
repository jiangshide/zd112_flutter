import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'application.dart';

class Translations{

  Locale locale;
  static Map<dynamic,dynamic> _localizedValues;

  Translations(Locale locale){
    this.locale = locale;
  }

  static Translations of(context){
    return Localizations.of(context, Translations);
  }

  String text(String key){
    if(null == _localizedValues)return key;
    return _localizedValues[key] ?? key;
  }

  static Future<Translations> load(Locale locale)async{
    Translations translations = Translations(locale);
    String languageCode = application.supportedLanguages.contains(locale.languageCode)?locale.languageCode:'en';
    String jsonContent = await rootBundle.loadString('assets/locale/i18n_$languageCode.json');
    _localizedValues = json.decode(jsonContent);
    return translations;
  }

  get currentLanguage => locale.languageCode;
}

class TranslationsDelegate extends LocalizationsDelegate<Translations>{
  const TranslationsDelegate();

  @override
  bool isSupported(Locale locale) => application.supportedLanguages.contains(locale.languageCode);

  @override
  Future<Translations> load(Locale locale) => Translations.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<Translations> old) => false;
}

class SpecificLocalizationDelegate extends LocalizationsDelegate<Translations>{
  final Locale locale;

  const SpecificLocalizationDelegate(this.locale);

  @override
  bool isSupported(Locale locale) => null != locale;

  @override
  Future<Translations> load(Locale locale) => Translations.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<Translations> old) => true;
}