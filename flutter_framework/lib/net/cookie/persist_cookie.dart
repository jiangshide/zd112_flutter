import 'dart:io';
import 'dart:convert';

import 'default_cookie.dart';
import 'serializable_cookie.dart';

class PersistCookie extends DefaultCookie {
  List<String> _cookieDomains;
  String _dir;
  static final Map<String, PersistCookie> _dirMaps =
  <String, PersistCookie>{};

  factory PersistCookie([String dir = './.cookies/']) {
    if (!dir.endsWith('/')) {
      dir += '/';
    }
    final Directory directory = new Directory(dir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    _dirMaps[dir] ??= new PersistCookie._init(dir);
    return _dirMaps[dir];
  }

  PersistCookie._init(this._dir) {
    File file = new File('$_dir.domains');
    if (file.existsSync()) {
      try {
        final Map<String, dynamic> jsonData = json.decode(
            file.readAsStringSync());

        final Map<String,
            Map<String, Map<String, SerializableCookie>>> cookies = jsonData
            .map((String domain, dynamic _cookies) {
          final Map<String, dynamic> cookies = _cookies.cast<String, dynamic>();
          final Map<String,
              Map<String, SerializableCookie>> domainCookies = cookies.map((
              String path, dynamic map) {
            final Map<String, String> cookieForPath = map.cast<String,
                String>();
            final Map<String, SerializableCookie> realCookies = cookieForPath
                .map((String cookieName, String cookie) =>
            new MapEntry<String, SerializableCookie>(
                cookieName, new SerializableCookie.fromJson(cookie)));
            return new MapEntry<String, Map<String, SerializableCookie>>(
                path, realCookies);
          });
          return new MapEntry<String,
              Map<String, Map<String, SerializableCookie>>>(
              domain, domainCookies);
        });

        domains[0] = cookies;
      } catch (e) {
        file.delete();
      }
    }
    if (_cookieDomains == null) {
      file = new File('$_dir.index');
      if (file.existsSync()) {
        try {
          final List<dynamic> list = json.decode(file.readAsStringSync());
          _cookieDomains = list.cast<String>();
          return;
        } catch (e) {
          file.delete();
        }
      }
    }
    _cookieDomains = <String>[];
  }

  @override
  List<Cookie> loadForRequest(Uri uri) {
    _load(uri);
    return super.loadForRequest(uri);
  }

  @override
  void saveFromResponse(Uri uri, List<Cookie> cookies) {
    if (cookies.isNotEmpty) {
      super.saveFromResponse(uri, cookies);
      if (cookies.every((Cookie e) => e.domain == null)) {
        _save(uri);
      } else {
        _save(uri, true);
      }
    }
  }

  Map<String, Map<String, SerializableCookie>> _filter(
      Map<String, Map<String, SerializableCookie>> domain,
      [bool keepSession = true]) {
    return domain.cast<String, Map<String, dynamic>>().map((String path,
        Map<String, dynamic> _cookies) {
      final Map<String, SerializableCookie> cookies = _cookies.map((
          String cookieName, dynamic cookie) {
        if (((cookie.cookie.expires == null && cookie.cookie.maxAge == null) &&
            keepSession) || !cookie.isExpired()) {
          return new MapEntry<String, SerializableCookie>(cookieName, cookie);
        } else
          return new MapEntry<String, SerializableCookie>(null, cookie);
      })
        ..removeWhere((String k, SerializableCookie v) => k == null);

      return new MapEntry<String, Map<String, SerializableCookie>>(
          path, cookies);
    });
  }

  void delete(Uri uri, [bool withDomainSharedCookie = false]) {
    final String host = '${uri.host}${uri.port}';
    File file;
    if (_cookieDomains.remove(host)) {
      file = new File('$_dir.index');
      file.writeAsStringSync(json.encode(_cookieDomains));
    }
    domains[1].remove(host);
    file = new File('$_dir$host');
    if (file.existsSync()) {
      file.delete();
    }
    if (withDomainSharedCookie) {
      domains[0].removeWhere((String domain,
          Map<String, Map<String, SerializableCookie>>v) =>
          uri.host.contains(domain));
      file = new File('$_dir.domains');
      file.writeAsStringSync(json.encode(domains[0]));
    }
  }

  void deleteAll() {
    Directory directory = new Directory(_dir);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
    _cookieDomains?.clear();
    _dirMaps.remove(_dir);
  }

  void _save(Uri uri, [bool withDomainSharedCookie = false]) {
    final String host = '${uri.host}${uri.port}';
    File file;
    if (!_cookieDomains.contains(host)) {
      _cookieDomains.add(host);
      file = new File('$_dir.index');
      file.writeAsStringSync(json.encode(_cookieDomains));
    }
    if (domains[1][host] != null) {
      file = new File('$_dir$host');
      file.writeAsStringSync(json.encode(_filter(domains[1][host])));
    }
    if (withDomainSharedCookie) {
      file = new File('$_dir.domains');
      final Map<String,
          Map<String, Map<String, SerializableCookie>>> newDomains =
      <String, Map<String, Map<String, SerializableCookie>>>{};
      domains[0].forEach((String domain,
          Map<String, Map<String, SerializableCookie>> map) {
        newDomains[domain] = _filter(map);
      });
      file.writeAsStringSync(json.encode(newDomains));
    }
  }

  void _load(Uri uri) {
    final String host = '${uri.host}${uri.port}';
    final File file = new File('$_dir$host');
    if (_cookieDomains.contains(host) && domains[1][host] == null) {
      if (file.existsSync()) {
        Map<String, Map<String, dynamic>> cookies;
        try {
          cookies = json.decode(file.readAsStringSync()).cast<String,
              Map<String, dynamic>>();
          cookies.forEach((String path, Map<String, dynamic> map) {
            map.forEach((String k, dynamic v) {
              map[k] = new SerializableCookie.fromJson(v);
            });
          });
          domains[1][host] =
              cookies.cast<String, Map<String, SerializableCookie>>();
        } catch (e) {
          file.delete();
          //rethrow;
        }
      }
    }
  }
}