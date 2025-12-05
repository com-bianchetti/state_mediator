import 'package:flutter/material.dart';
import 'package:state_mediator/components/result.dart';

class StateBuilder<T> extends StatelessWidget {
  final ValueNotifier<Result> state;
  final WidgetBuilder? onLoading;
  final Widget Function(Object error)? onError;
  final Widget Function(T data)? onSuccess;
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
