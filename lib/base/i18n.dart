import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class Local implements WidgetsLocalizations{
  const Local();

  static const GeneratedLocalizationsDelegate delegate = GeneratedLocalizationsDelegate();

  static Local of(context) => Localizations.of(context,Local);

  @override
  TextDirection get textDirection => TextDirection.ltr;
}

class $en extends Local{
  const $en();
}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<Local>{
  const GeneratedLocalizationsDelegate();

  List<Locale> get supportedLocales{
    return const <Locale>[Locale('en','')];
  }

  LocaleListResolutionCallback listResolutionCallback({Locale fallBack}){
    return (List<Locale> locales,Iterable<Locale> supported){
      if(null == locales || locales.isEmpty)return fallBack ?? supported.first;
      return _resolve(locales.first,fallBack,supported);
    };
  }

  LocaleResolutionCallback resolution({Locale fallback}){
    return (Locale locale,Iterable<Locale> supported){
      return _resolve(locale,fallback,supported);
    };
  }

  Locale _resolve(Locale locale,Locale fallback,Iterable<Locale> supported){
    if(null == locale || !isSupported(locale)){
      return fallback ?? supported.first;
    }

    final Locale languageLocale = Locale(locale.languageCode,'');
    if(supported.contains(locale))return locale;
    else if(supported.contains(languageLocale))return languageLocale;
    else{
      final Locale fallbackLocale = fallback ?? supported.first;
      return fallbackLocale;
    }
  }

  @override
  Future<Local> load(Locale locale) {
    final String lang = getLang(locale);
    if(null != lang){
      switch(lang){
        case 'en':
          return SynchronousFuture<Local>(const $en());
      }
    }
    return SynchronousFuture<Local>(const Local());
  }

  @override
  bool isSupported(Locale locale)  => null != locale && supportedLocales.contains(locale);

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => false;
}

String getLang(Locale locale) => null == locale ? null : locale.countryCode != null && locale.countryCode.isEmpty ? locale.languageCode : locale.toString();