import 'package:state_mediator/components/command.dart';

class CountCommand extends Command<int> {
  @override
  int? updateState(int? previousState) {
    return (previousState ?? 0) + 1;
  }
}
