import 'dart:async';

import 'package:flutter/material.dart';
import 'package:state_mediator/state_mediator.dart';

mixin Mediator<T extends StatefulWidget> on State<T> {
  final Map<String, ValueNotifier<Result>> _state = {};

  ValueNotifier<Result> state<E>([String? id]) {
    return _state[id ?? E.toString()] ?? ValueNotifier(Result.loading());
  }

  FutureOr<void> dispatch(Command command) async {
    final state = _state[command.stateId ?? command.resultType.toString()];
    final handler = StateMediator.getHandler(command);

    try {
      state?.value = Result.loading();
      final result = await handler.handle(command, state?.value.data);
      if (result != null) {
        state?.value = Result.success(result);
      }
    } catch (e, stackTrace) {
      StateMediator.errorHandler(e, stackTrace);
    }
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
