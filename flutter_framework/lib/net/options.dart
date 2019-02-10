import 'dart:io';

enum ResponseType {
  JSON,
  STREAM,
  PLAIN
}

typedef bool ValidateStatus(int status);

class Options {
  Options({
    this.method,
    this.baseUrl,
    this.connectTimeout,
    this.receiveTimeout,
    this.path,
    this.data,
    this.extra,
    this.headers,
    this.responseType,
    this.contentType,
    this.validateStatus,
    this.followRedirects:true
  }) {
    // set the default user-agent with Dio version
    this.headers = headers ?? {};

    this.extra = extra ?? {};
  }

  Options merge({
    String method,
    String baseUrl,
    String path,
    int connectTimeout,
    int receiveTimeout,
    dynamic data,
    Map<String, dynamic> extra,
    Map<String, dynamic> headers,
    ResponseType responseType,
    ContentType contentType,
    ValidateStatus validateStatus,
    bool followRedirects
  }) {
    return new Options(
      method: method??this.method,
      baseUrl: baseUrl??this.baseUrl,
      path: path??this.path,
      connectTimeout: connectTimeout??this.connectTimeout,
      receiveTimeout: receiveTimeout??this.receiveTimeout,
      data: data??this.data,
      extra: extra??new Map.from(this.extra??{}),
      headers: headers??new Map.from(this.headers??{}),
      responseType: responseType??this.responseType,
      contentType: contentType??this.contentType,
      validateStatus: validateStatus??this.validateStatus,
      followRedirects: followRedirects??this.followRedirects
    );
  }

  String method;
  String baseUrl;
  Map<String, dynamic> headers;
  int connectTimeout;
  int receiveTimeout;
  dynamic data;
  String path = "";
  ContentType contentType;
  ResponseType responseType;
  ValidateStatus validateStatus;
  Map<String, dynamic> extra;
  bool followRedirects;
}
