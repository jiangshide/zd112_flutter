import 'dart:async';
import 'net_error.dart';

class CancelToken {

  static bool isCancel(NetError e) {
    return e.type == ErrorType.CANCEL;
  }

  NetError get cancelError => _cancelError;

  void cancel([String msg]) {
    _cancelError = new NetError(message: msg, type: ErrorType.CANCEL);
    if (!completers.isEmpty) {
       completers.forEach((e)=>e.completeError(cancelError));
    }
  }
  
  _trigger(completer) {
    if (completer!=null) {
      completer.completeError(cancelError);
      completers.remove(completer);
    }
  }

  void addCompleter(Completer completer){
    if (cancelError != null) {
      _trigger(completer);
    }else{
      if(!completers.contains(completer)){
        completers.add(completer);
      }
    }
  }

  void removeCompleter(Completer completer){
    completers.remove(completer);
  }

  var completers =new List<Completer>();
  NetError _cancelError;

}
