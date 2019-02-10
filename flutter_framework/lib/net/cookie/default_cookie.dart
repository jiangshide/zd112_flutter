import 'dart:io';
import 'cookies.dart';
import 'serializable_cookie.dart';

class DefaultCookie implements Cookies {
  List<
      Map<
          String, //domain
          Map<
              String, //path
              Map<
                  String, //cookie name
                  SerializableCookie //cookie
              >>>> domains = <
      Map<String, Map<String, Map<String, SerializableCookie>>>>[
    <String, Map<String, Map<String, SerializableCookie>>>{},
    <String, Map<String, Map<String, SerializableCookie>>>{}
  ];

  @override
  List<Cookie> loadForRequest(Uri uri) {
    final List<Cookie> list = <Cookie>[];
    final String urlPath = uri.path.isEmpty ? '/' : uri.path;
    // Load cookies with "domain" attribute, Ignore port.
    domains[0].forEach((String domain,
        Map<String, Map<String, SerializableCookie>> cookies) {
      if (uri.host.contains(domain)) {
        cookies.forEach((String path, Map<String, SerializableCookie> values) {
          if (urlPath.toLowerCase().contains(path)) {
            values.forEach((String key, SerializableCookie v) {
              if (_check(uri.scheme, v)) {
                list.add(v.cookie);
              }
            });
          }
        });
      }
    });
    final String hostname = '${uri.host}${uri.port}';

    for (String domain in domains[1].keys) {
      if (hostname == domain) {
        final Map<String, Map<String, dynamic>> cookies = domains[1][domain]
            .cast<String, Map<String, dynamic>>();

        for (String path in cookies.keys) {
          if (urlPath.toLowerCase().contains(path)) {
            final Map<String, dynamic> values = cookies[path];
            for (String key in values.keys) {
              final SerializableCookie cookie = values[key];
              if (_check(uri.scheme, cookie)) {
                list.add(cookie.cookie);
              }
            }
          }
        }
      }
    }
    return list;
  }

  @override
  void saveFromResponse(Uri uri, List<Cookie> cookies) {
    for (Cookie cookie in cookies) {
      String domain = cookie.domain;
      // Save cookies with "domain" attribute, Ignore port.
      if (domain != null) {
        if (domain.startsWith('.')) {
          domain = domain.substring(1);
        }
        final String path = cookie.path ?? '/';

        final Map<String, Map<String, SerializableCookie>> mapDomain =
            domains[0][domain] ?? <String, Map<String, SerializableCookie>>{};
        final Map<String, SerializableCookie> map = mapDomain[path] ??
            <String, SerializableCookie>{};
        map[cookie.name] = new SerializableCookie(cookie);
        mapDomain[path] = map;
        domains[0][domain] = mapDomain;
      } else {
        final String path = cookie.path ?? (uri.path.isEmpty ? '/' : uri.path);
        final String domain = '${uri.host}${uri.port}';

        Map<String, Map<String, dynamic>> mapDomain = domains[1][domain] ??
            <String, Map<String, dynamic>>{};
        mapDomain = mapDomain.cast<String, Map<String, dynamic>>();

        final Map<String, dynamic> map = mapDomain[path] ?? <String, dynamic>{};
        map[cookie.name] = new SerializableCookie(cookie);
        mapDomain[path] = map.cast<String, SerializableCookie>();
        domains[1][domain] =
            mapDomain.cast<String, Map<String, SerializableCookie>>();
      }
    }
  }

  void delete(Uri uri, [bool withDomainSharedCookie = false]) {
    final String host = '${uri.host}${uri.port}';
    domains[1].remove(host);
    if (withDomainSharedCookie) {
      domains[0].removeWhere((String domain,
          Map<String, Map<String, SerializableCookie>>v) =>
          uri.host.contains(domain));
    }
  }

  void deleteAll(){
    domains.clear();
  }

  bool _check(String scheme, SerializableCookie cookie) {
    return cookie.cookie.secure && scheme == 'https' || !cookie.isExpired();
  }
}