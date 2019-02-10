import 'dart:async';

typedef State Reducer<State>(State state, dynamic action);

abstract class ReducerClass<State> {
  State call(State state, dynamic action);
}

typedef void Middleware<State>(
    Store<State> store,
    dynamic action,
    NextDispatcher next,);

abstract class MiddlewareClass<State> {
  void call(Store<State> store, dynamic action, NextDispatcher next);
}

typedef void NextDispatcher(dynamic action);

class Store<State> {
  Reducer<State> reducer;

  final StreamController<State> _changeController;
  State _state;
  List<NextDispatcher> _dispatchers;

  Store(
      this.reducer, {
        State initialState,
        List<Middleware<State>> middleware = const [],
        bool syncStream: false,

        bool distinct: false,
      })
      : _changeController = new StreamController.broadcast(sync: syncStream) {
    _state = initialState;
    _dispatchers = _createDispatchers(
      middleware,
      _createReduceAndNotify(distinct),
    );
  }

  State get state => _state;

  Stream<State> get onChange => _changeController.stream;

  NextDispatcher _createReduceAndNotify(bool distinct) {
    return (dynamic action) {
      final state = reducer(_state, action);

      if (distinct && state == _state) return;

      _state = state;
      _changeController.add(state);
    };
  }

  List<NextDispatcher> _createDispatchers(
      List<Middleware<State>> middleware,
      NextDispatcher reduceAndNotify,
      ) {
    final dispatchers = <NextDispatcher>[]..add(reduceAndNotify);

    for (var nextMiddleware in middleware.reversed) {
      final next = dispatchers.last;

      dispatchers.add(
            (dynamic action) => nextMiddleware(this, action, next),
      );
    }

    return dispatchers.reversed.toList();
  }

  void dispatch(dynamic action) {
    _dispatchers[0](action);
  }

  Future teardown() async {
    _state = null;
    return _changeController.close();
  }
}