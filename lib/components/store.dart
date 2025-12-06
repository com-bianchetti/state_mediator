import 'package:flutter/material.dart';
import 'package:state_mediator/components/result.dart';

/// A state store is a class that stores the state of the application.
/// It is used to store the state of the application so that it can be
/// shared between multiple widgets and mediators.
///
/// The [state] is the map that stores the states of the application.
/// The key is the id of the state and the value is the [ValueNotifier]
/// that will notify the widget when the state changes.
abstract class StateStore {
  /// The map that stores the states of the application.
  /// The key is the id of the state and the value is the [ValueNotifier]
  /// that will notify the widget when the state changes.
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
