import 'dart:io';
import 'options.dart';

class Response<T> {
  Response({this.data, this.headers, this.request, this.statusCode = 0});
  T data;
  HttpHeaders headers;
  Options request;
  int statusCode;
  Map<String, dynamic> extra;
  @override
  String toString() => "[data]=" + data.toString();
}