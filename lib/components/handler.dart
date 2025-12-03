import 'dart:async';

import 'package:state_mediator/state_mediator.dart';

abstract class CommandHandler<C extends Command, R> {
  FutureOr<R> handle(C command);
}
