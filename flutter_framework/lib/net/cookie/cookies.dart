import 'dart:io';
import 'default_cookie.dart';

abstract class Cookies {
  factory Cookies() = DefaultCookie;

  void saveFromResponse(Uri uri, List<Cookie> cookies);

  List<Cookie> loadForRequest(Uri uri);
}