import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'net_error.dart';
import 'options.dart';

abstract class Transformer {
  Future<String> transformRequest(Options options);
  Future transformResponse(Options options, HttpClientResponse response);
  static String urlEncodeMap(data) {
    StringBuffer urlData = new StringBuffer("");
    bool first = true;
    void urlEncode(dynamic sub, String path) {
      if (sub is List) {
        for (int i = 0; i < sub.length; i++) {
          int index=(sub[i] is Map||sub[i] is List) ? i : null;
          urlEncode(sub[i], "$path%5B$index%5D");
        }
      } else if (sub is Map) {
        sub.forEach((k, v) {
          if (path == "") {
            urlEncode(v, "${Uri.encodeQueryComponent(k)}");
          } else {
            urlEncode(v, "$path%5B${Uri.encodeQueryComponent(k)}%5D");
          }
        });
      } else {
        if (!first) {
          urlData.write("&");
        }
        first = false;
        urlData.write("$path=${Uri.encodeQueryComponent(sub.toString())}");
      }
    }
    urlEncode(data, "");
    return urlData.toString();
  }
}

class DefaultTransformer extends Transformer {

  Future<String> transformRequest(Options options) async {
    var data = options.data ?? "";
    if (data is! String) {
      if (options.contentType.mimeType == ContentType.json.mimeType) {
        return json.encode(options.data);
      } else if (data is Map) {
        return Transformer.urlEncodeMap(data);
      }
    }
    return data.toString();
  }

  Future transformResponse(Options options, HttpClientResponse response) async {
    if (options.responseType == ResponseType.STREAM) {
      return response;
    }
    // Handle timeout
    Stream<List<int>> stream = response;
    if (options.receiveTimeout > 0) {
      stream = stream.timeout(
          new Duration(milliseconds: options.receiveTimeout),
          onTimeout: (EventSink sink) {
            sink.addError(new NetError(
              message: "Receiving data timeout[${options
                  .receiveTimeout}ms]",
              type: ErrorType.RECEIVE_TIMEOUT,
            ));
            sink.close();
          });
    }
    String responseBody = await stream.transform(Utf8Decoder(allowMalformed: true)).join();
    if (responseBody != null
        && responseBody.isNotEmpty
        && options.responseType == ResponseType.JSON
        && response.headers.contentType?.mimeType == ContentType.json.mimeType) {
      return json.decode(responseBody);
    }
    return responseBody;
  }
}
