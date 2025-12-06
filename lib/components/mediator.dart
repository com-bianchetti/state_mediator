import 'dart:async';

import 'package:flutter/material.dart';
import 'package:state_mediator/state_mediator.dart';

/// A mediator is a class that manages the state of the application.
/// Use this mixin in your stateful widget to manage one or more states, saving
/// you from writing the boilerplate code to manage states. Using the mediator,
/// you don't have to manually manage success, loading, and error states. Just
/// dispatch a command and use the state getter to get the state. The mediator
/// handles the state lifecycle automatically.
///
/// The [T] is the type of the stateful widget.
///
/// The [state] getter is used to get a state by type or id.
/// It will return a [ValueNotifier] to notify the widget when the state changes.
/// States are usually identified by it's type. Optionally, you can pass a custom id
/// to the state getter to get a specific state by id. This is useful when you have
/// multiple states with the same type.
///
/// The [initStateStore] method is used to initialize the mediator with a store.
/// The store is a class that extends [StateStore] and contains the state
/// than can be shared between multiple widgets and mediators.
///
/// The [dispatchAsync] method is used to dispatch a command asynchronously.
/// The command will be handled by the mediator and the state will be updated accordingly.
///
/// The [dispatch] method is used to dispatch a command synchronously.
/// The command will be handled by the mediator and the state will be updated accordingly.
///
/// The [configMediator] method is used to configure the mediator.
/// You can pass a custom error handler to the mediator to handle errors.
mixin Mediator<T extends StatefulWidget> on State<T> {
  /// The map that stores the states of the application.
  /// The key is the id of the state and the value is the [ValueNotifier] that will notify the widget when the state changes.
  Map<String, ValueNotifier<Result>> _state = {};

  /// The error handler function.
  /// It will be called if an error occurs while handling a command.
  Result Function(Object e, StackTrace stackTrace)? _errorHandler;
  bool _isInitialized = false;

  /// The method to get a state.
  /// It will return a [ValueNotifier] that will notify the widget when the state changes.
  /// Optionally, you can pass a custom id to the state getter to get a specific state.
  /// This is useful when you have multiple states with the same type.
  ValueNotifier<Result> state<E>([String? id]) {
    if (_state[id ?? E.toString()] == null) {
      _state[id ?? E.toString()] = ValueNotifier(Result.loading());
    }
    return _state[id ?? E.toString()]!;
  }

  /// The method to initialize the mediator with a store.
  /// The store is a class that extends [StateStore] and contains the state of the application
  /// than can be shared between multiple widgets and mediators.
  void initStateStore(StateStore store) {
    _clearState();
    _isInitialized = true;
    _state = store.state;
  }

  /// The method to dispatch a command asynchronously.
  /// The command will be handled by the mediator and the state will be updated accordingly.
  Future<void> dispatchAsync(Command command) {
    return _dispatch(command, true);
  }

  /// The method to dispatch a command synchronously.
  /// The command will be handled by the mediator and the state will be updated accordingly.
  void dispatch(Command command) {
    _dispatch(command, false);
  }

  /// The method to dispatch a command.
  Future<void> _dispatch(Command command, bool isAsync) async {
    final state = _state[command.stateId ?? command.resultType.toString()];

    final newState = command.updateState(state?.value.data);

    if (newState != null) {
      state?.value = Result.success(newState);
      return;
    }

    final handler = StateMediator.getHandler(command);

    try {
      if (isAsync) {
        state?.value = Result.loading(state.value.data);
      }
      final result = await handler.handle(command, state?.value.data);
      if (result != null) {
        state?.value = Result.success(result);
      }
    } catch (e, stackTrace) {
      final errorHandler = _errorHandler ?? StateMediator.errorHandler;
      state?.value = errorHandler(e, stackTrace);
    }
  }

  /// The method to configure the mediator.
  /// You can pass a custom error handler to the mediator to handle errors.
  void configMediator({
    Result Function(Object e, StackTrace stackTrace)? errorHandler,
  }) {
    _errorHandler = errorHandler;
  }

  void _clearState() {
    for (final state in _state.values) {
      state.dispose();
    }

    _state.clear();
  }

  @override
  void dispose() {
    super.dispose();
    if (!_isInitialized) {
      _clearState();
    }
  }
}
