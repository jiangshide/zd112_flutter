import 'dart:io';

class SerializableCookie {
  SerializableCookie(this.cookie) {
    createTimeStamp = (new DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt();
  }

  SerializableCookie.fromJson(String value) {
    final List<String> t = value.split(';_crt=');
    cookie = new Cookie.fromSetCookieValue(t[0]);
    createTimeStamp = int.parse(t[1]);
  }

  bool isExpired() {
    final DateTime t = new DateTime.now();
    return (cookie.maxAge != null && cookie.maxAge < 1) ||
        (cookie.maxAge != null && (t.millisecondsSinceEpoch ~/ 1000).toInt() - createTimeStamp >= cookie.maxAge) ||
        (cookie.expires != null && !cookie.expires.isAfter(t));
  }

  String toJson() => toString();
  Cookie cookie;
  int createTimeStamp = 0;

  @override
  String toString() {
    return cookie.toString() + ';_crt=$createTimeStamp';
  }
}