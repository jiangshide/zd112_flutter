import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

class SpUtil{
  static SpUtil _singleton;
  static SharedPreferences _prefs;
  static Lock _lock = Lock();

  static Future<SpUtil> getInstance() async{
    if(null == _singleton){
      await _lock.synchronized(() async{
        if(null == _singleton){
          var singleton = SpUtil._();
          await singleton._init();
          _singleton = singleton;
        }
      });
    }
    return _singleton;
  }

  SpUtil._();

  Future _init() async{
    _prefs = await SharedPreferences.getInstance();
  }

  static String getString(String key){
    if(null == _prefs) return null;
    return _prefs.getString(key);
  }

  static bool getBool(String key){
    if(null == _prefs)return null;
    return _prefs.getBool(key);
  }

  static int getInt(String key){
    if(null == _prefs)return null;
    return _prefs.getInt(key);
  }

  static double getDouble(String key){
    if(null == _prefs)return null;
    return _prefs.getDouble(key);
  }

  static List<String> getStringList(String key){
    return _prefs.getStringList(key);
  }

  static dynamic getDynamic(String key){
    if(null == _prefs)return null;
    return _prefs.get(key);
  }

  static Set<String> getKeys(){
    if(null == _prefs) return null;
    return _prefs.getKeys();
  }

  static Future<bool> putString(String key,String value){
    if(null == _prefs) return null;
    return _prefs.setString(key, value);
  }

  static Future<bool> putBool(String key,bool value){
    if(null == _prefs) return null;
    return _prefs.setBool(key, value);
  }

  static Future<bool> putInt(String key,int value){
    if(null == _prefs) return null;
    return _prefs.setInt(key, value);
  }

  static Future<bool> putDouble(String key,double value){
    if(null != _prefs) return null;
    return _prefs.setDouble(key, value);
  }

  static Future<bool> putStringList(String key,List<String> value){
    if(null == _prefs)return null;
    return _prefs.setStringList(key, value);
  }

  static void putObject<T>(String key,Object value){
    switch(T){
      case int:
        putInt(key, value);
        break;
      case double:
        putDouble(key, value);
        break;
      case bool:
        putBool(key, value);
        break;
      case String:
        putString(key, value);
        break;
      case List:
        putStringList(key, value);
        break;
      default:
        putString(key,null == value ? '':json.encode(value));
    }
  }

  static Future<bool> remove(String key){
    if(null == _prefs) return null;
    return _prefs.remove(key);
  }

  static Future<bool> clear(){
    if(null == _prefs) return null;
    return _prefs.clear();
  }

  static bool isInitialized(){
    return null != _prefs;
  }
}


const MethodChannel _kChannel =
MethodChannel('plugins.flutter.io/shared_preferences');

/// Wraps NSUserDefaults (on iOS) and SharedPreferences (on Android), providing
/// a persistent store for simple data.
///
/// Data is persisted to disk asynchronously.
class SharedPreferences {
  SharedPreferences._(this._preferenceCache);

  static const String _prefix = 'flutter.';
  static SharedPreferences _instance;
  static Future<SharedPreferences> getInstance() async {
    if (_instance == null) {
      final Map<Object, Object> fromSystem =
      // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
      await _kChannel.invokeMethod('getAll');
      assert(fromSystem != null);
      // Strip the flutter. prefix from the returned preferences.
      final Map<String, Object> preferencesMap = <String, Object>{};
      for (String key in fromSystem.keys) {
        assert(key.startsWith(_prefix));
        preferencesMap[key.substring(_prefix.length)] = fromSystem[key];
      }
      _instance = SharedPreferences._(preferencesMap);
    }
    return _instance;
  }

  /// The cache that holds all preferences.
  ///
  /// It is instantiated to the current state of the SharedPreferences or
  /// NSUserDefaults object and then kept in sync via setter methods in this
  /// class.
  ///
  /// It is NOT guaranteed that this cache and the device prefs will remain
  /// in sync since the setter method might fail for any reason.
  final Map<String, Object> _preferenceCache;

  /// Returns all keys in the persistent storage.
  Set<String> getKeys() => Set<String>.from(_preferenceCache.keys);

  /// Reads a value of any type from persistent storage.
  dynamic get(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// bool.
  bool getBool(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not
  /// an int.
  int getInt(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// double.
  double getDouble(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// String.
  String getString(String key) => _preferenceCache[key];

  /// Reads a set of string values from persistent storage, throwing an
  /// exception if it's not a string set.
  List<String> getStringList(String key) {
    List<Object> list = _preferenceCache[key];
    if (list != null && list is! List<String>) {
      list = list.cast<String>().toList();
      _preferenceCache[key] = list;
    }
    return list;
  }

  /// Saves a boolean [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setBool(String key, bool value) => _setValue('Bool', key, value);

  /// Saves an integer [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setInt(String key, int value) => _setValue('Int', key, value);

  /// Saves a double [value] to persistent storage in the background.
  ///
  /// Android doesn't support storing doubles, so it will be stored as a float.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setDouble(String key, double value) =>
      _setValue('Double', key, value);

  /// Saves a string [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setString(String key, String value) =>
      _setValue('String', key, value);

  /// Saves a list of strings [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setStringList(String key, List<String> value) =>
      _setValue('StringList', key, value);

  /// Removes an entry from persistent storage.
  Future<bool> remove(String key) => _setValue(null, key, null);

  Future<bool> _setValue(String valueType, String key, Object value) {
    final Map<String, dynamic> params = <String, dynamic>{
      'key': '$_prefix$key',
    };
    if (value == null) {
      _preferenceCache.remove(key);
      return _kChannel
      // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
          .invokeMethod('remove', params)
          .then<bool>((dynamic result) => result);
    } else {
      _preferenceCache[key] = value;
      params['value'] = value;
      return _kChannel
      // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
          .invokeMethod('set$valueType', params)
          .then<bool>((dynamic result) => result);
    }
  }

  /// Always returns true.
  /// On iOS, synchronize is marked deprecated. On Android, we commit every set.
  @deprecated
  // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
  // https://github.com/flutter/flutter/issues/26431
  // ignore: strong_mode_implicit_dynamic_method
  Future<bool> commit() async => await _kChannel.invokeMethod('commit');

  /// Completes with true once the user preferences for the app has been cleared.
  Future<bool> clear() async {
    _preferenceCache.clear();
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return await _kChannel.invokeMethod('clear');
  }

  /// Initializes the shared preferences with mock values for testing.
  @visibleForTesting
  static void setMockInitialValues(Map<String, dynamic> values) {
    _kChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return values;
      }
      return null;
    });
  }
}