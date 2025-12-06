import 'dart:async';

import 'package:state_mediator/state_mediator.dart';

/// A command handler is a class that handles a command and updates the state of the application.
/// Extend this class to create a new handler for a command.
///
/// The [C] is the type of the command to handle.
/// The [R] is the type of the state to update.
///
/// The [handle] method is used to handle the command and update the state.
/// It will receive the command and the previous state as arguments and should return the new state.
/// This method is called by the [Mediator] to handle the command. Remember to register
/// the handler in the [StateMediator] before using the [Mediator].
abstract class CommandHandler<C extends Command, R> {
  /// The method to handle the command and update the state.
  /// It will receive the command and the previous state as arguments and should return the new state.
  /// This method is called by the [Mediator] to handle the command.
  FutureOr<R?> handle(C command, R? previousState);
}
