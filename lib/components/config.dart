import 'package:state_mediator/state_mediator.dart';

/// The [StateMediator] is a class that stores the configuration for the mediator
/// and provides a way to register handlers for commands. All handlers must be
/// registered before using the [Mediator] to ensure that the commands are
/// handled correctly.
///
/// The [errorHandler] is a function that will be called if an error occurs
/// while handling a command. By default, the error handler will do nothing.
///
/// The [handlers] is a map that stores the registered handlers for commands.
/// The key is the type of the command and the value is the handler.
///
/// The [registerHandler] method is used to register a new handler for a command.
///
/// The [getHandler] method is used by the [Mediator] to get a handler for a command.
/// It will throw an error if no handler is registered for the command type.
class StateMediator {
  static Result Function(Object e, StackTrace stackTrace) errorHandler =
      _defaultErrorHandler;

  /// The map that stores the registered handlers for commands.
  /// The key is the type of the command and the value is the handler.
  static final Map<Type, CommandHandler<Command, dynamic>> _handlers = {};

  /// The method to register a new handler for a command.
  /// The handler will be stored in the map with the command type as the key.
  static void registerHandler<C extends Command>(CommandHandler handler) {
    _handlers[C] = handler;
  }

  /// The method to get a handler for a command.
  /// It will throw an error if no handler is registered for the command type.
  static CommandHandler getHandler<C extends Command>(C command) {
    final handler = _handlers[command.runtimeType];
    if (handler == null) {
      throw StateError(
        'No handler registered for command type: ${command.runtimeType}',
      );
    }
    return handler;
  }

  static Result _defaultErrorHandler(Object e, StackTrace stackTrace) {
    return Result.error(e.toString());
  }
}
