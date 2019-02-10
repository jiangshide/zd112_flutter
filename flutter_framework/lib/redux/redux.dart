import 'store.dart';

class TypedReducer<State, Action> implements ReducerClass<State> {
  final State Function(State state, Action action) reducer;

  TypedReducer(this.reducer);

  @override
  State call(State state, dynamic action) {
    if (action is Action) {
      return reducer(state, action);
    }

    return state;
  }
}

class TypedMiddleware<State, Action> implements MiddlewareClass<State> {
  final void Function(
      Store<State> store,
      Action action,
      NextDispatcher next,
      ) middleware;

  TypedMiddleware(this.middleware);

  @override
  void call(Store<State> store, dynamic action, NextDispatcher next) {
    if (action is Action) {
      middleware(store, action, next);
    } else {
      next(action);
    }
  }
}

Reducer<State> combineReducers<State>(Iterable<Reducer<State>> reducers) {
  return (State state, dynamic action) {
    for (final reducer in reducers) {
      state = reducer(state, action);
    }
    return state;
  };
}