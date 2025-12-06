import 'package:flutter/material.dart';
import 'package:state_mediator/components/result.dart';

/// A state builder is a widget that builds a widget based on the state of the application.
/// It is used to build a widget based on the state of the application.
///
/// The [T] is the type of the data.
///
/// The [state] is the state of the application.
/// The [onLoading] is the widget to build when the state is loading.
/// The [onError] is the widget to build when the state is error.
/// The [onSuccess] is the widget to build when the state is success.
class StateBuilder<T> extends StatelessWidget {
  /// The state of the application.
  final ValueNotifier<Result> state;

  /// The widget to build when the state is loading.
  final WidgetBuilder? onLoading;

  /// The widget to build when the state is error.
  final Widget Function(Object error)? onError;

  /// The widget to build when the state is success.
  final Widget Function(T data)? onSuccess;

  /// The builder function to build the widget based on the state.
  final Widget Function(bool isLoading, T? data, Object? error)? builder;

  const StateBuilder({
    super.key,
    required this.state,
    this.onLoading,
    this.onError,
    this.onSuccess,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<dynamic>(
      valueListenable: state,
      builder: builder != null
          ? (context, result, _) =>
                builder!(result.isLoading, result.data as T?, result.error)
          : (context, result, _) {
              if (result.isLoading) {
                return onLoading?.call(context) ?? const SizedBox.shrink();
              }

              if (result.isSuccess) {
                return onSuccess?.call(result.data as T) ??
                    const SizedBox.shrink();
              }

              return onError?.call(result.error as Object) ??
                  const SizedBox.shrink();
            },
    );
  }
}
