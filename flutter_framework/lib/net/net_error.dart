import 'response.dart';

enum ErrorType {
  DEFAULT,
  CONNECT_TIMEOUT,
  RECEIVE_TIMEOUT,
  RESPONSE,
  CANCEL
}

class NetError extends Error {
  NetError({this.response, this.message, this.type = ErrorType
      .DEFAULT, this.stackTrace});
  Response response;
  String message;
  ErrorType type;
  String toString() =>
      "DioError [$type]: " + message + (stackTrace ?? "").toString();
  StackTrace stackTrace;
}