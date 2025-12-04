import 'dart:async';

import 'package:flutter/material.dart';
import 'package:state_mediator/state_mediator.dart';

mixin Mediator<T extends StatefulWidget> on State<T> {
  final Map<String, ValueNotifier<Result>> _state = {};
  void Function(Object e, StackTrace stackTrace)? _errorHandler;

  ValueNotifier<Result> state<E>([String? id]) {
    return _state[id ?? E.toString()] ?? ValueNotifier(Result.loading());
  }

  Future<void> dispatch(Command command) async {
    final state = _state[command.stateId ?? command.resultType.toString()];
    final handler = StateMediator.getHandler(command);

    try {
      state?.value = Result.loading();
      final result = await handler.handle(command, state?.value.data);
      if (result != null) {
        state?.value = Result.success(result);
      }
    } catch (e, stackTrace) {
      final errorHandler = _errorHandler ?? StateMediator.errorHandler;
      errorHandler(e, stackTrace);
      state?.value = Result.error(e.toString());
    }
  }

  void configMediator({
    void Function(Object e, StackTrace stackTrace)? errorHandler,
  }) {
    _errorHandler = errorHandler;
  }

  @override
  void dispose() {
    super.dispose();
    for (final state in _state.values) {
      state.dispose();
    }

    _state.clear();
  }
}
