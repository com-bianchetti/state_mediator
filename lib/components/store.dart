import 'package:flutter/material.dart';
import 'package:state_mediator/components/result.dart';

abstract class StateStore {
  late Map<String, ValueNotifier<Result>> state;

  StateStore({Map<String, ValueNotifier<Result>>? state}) {
    this.state = state ?? {};
  }

  void dispose() {
    for (final state in state.values) {
      state.dispose();
    }
    state.clear();
  }
}
