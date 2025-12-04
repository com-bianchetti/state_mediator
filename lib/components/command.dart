abstract class Command<T> {
  Type get resultType => T;

  String? get stateId => null;
}
