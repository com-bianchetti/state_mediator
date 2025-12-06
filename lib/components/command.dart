/// A command is a request to update the state of the application.
/// Extend this class to create a new command with all the
/// necessary information as properties to update a specific state.
///
/// The [T] is the type of the state to update. By default, the state type will be
/// used to identify the state to update on the [Mediator].
///
/// Optionally, you can override the [stateId] property to specify a
/// custom state id to identify the state to update on the [Mediator]. Doing
/// this will make the state be identified by the custom id instead of the state type.
/// This is useful when you have multiple states with the same type.
///
/// Sometimes you may need to do quick state updates without needing a
/// dedicated handler for a command. In this case, you can override the [updateState] method
/// to update the state directly. The function will receive the previous
/// state as an argument and should return the new state.
abstract class Command<T> {
  /// The type of the state to update. By default, the state type will be
  /// used to identify the state to update on the [Mediator].
  Type get resultType => T;

  /// The id of the state to update. By default, the state type will be
  /// used to identify the state to update on the [Mediator].
  String? get stateId => null;

  /// The function to update the state. By default, the function will return null.
  /// This is useful when you need to do quick state updates without needing a
  /// dedicated handler for a command. The function will receive the previous
  /// state as an argument and should return the new state.
  T? updateState(T? previousState) {
    return null;
  }
}
