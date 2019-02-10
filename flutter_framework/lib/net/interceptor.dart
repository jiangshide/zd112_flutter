import 'dart:async';

import 'net_error.dart';
import 'options.dart';
import 'response.dart';

typedef InterceptorCallback(Options options);
typedef InterceptorErrorCallback(NetError e);
typedef InterceptorsSuccessCallback(Response e);

abstract class _InterceptorBase {
  Future _lock;
  Completer _completer;

  bool get locked => _lock != null;

  void lock() {
    if (!locked) {
      _completer = new Completer();
      _lock = _completer.future;
    }
  }

  void unlock() {
    if (locked) {
      _completer.complete();
      _lock=null;
    }
  }

  void clear([String msg="cancelled"]){
    if(locked) {
      _completer.completeError(msg);
      _lock = null;
    }
  }

  Future<Response> enqueue(Future<Response> callback()) {
    if (locked) {
      // we use a future as a queue
      return _lock.then((d) => callback());
    }
    return null;
  }
}

class RequestInterceptor extends _InterceptorBase {
  InterceptorCallback onSend;
}

class ResponseInterceptor extends _InterceptorBase {
  InterceptorsSuccessCallback onSuccess;
  InterceptorErrorCallback onError;
}

class Interceptor {
  var _request = new RequestInterceptor();
  var _response = new ResponseInterceptor();

  RequestInterceptor get request => _request;

  ResponseInterceptor get response => _response;
}