import 'package:state_mediator/state_mediator.dart';

class StateMediator {
  static void Function(Object e, StackTrace stackTrace) errorHandler =
      _defaultErrorHandler;

  static final Map<Type, CommandHandler<Command, dynamic>> _handlers = {};

  static void registerHandler<C extends Command>(CommandHandler handler) {
    _handlers[C] = handler;
  }

  static CommandHandler getHandler<C extends Command>(C command) {
    final handler = _handlers[command.runtimeType];
    if (handler == null) {
      throw StateError(
        'No handler registered for command type: ${command.runtimeType}',
      );
    }
    return handler;
  }

  static void _defaultErrorHandler(Object e, StackTrace stackTrace) {
    throw e;
  }
}
