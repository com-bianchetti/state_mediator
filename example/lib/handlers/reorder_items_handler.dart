import 'dart:async';

import 'package:example/commands/items_command.dart';
import 'package:example/models/item_model.dart';
import 'package:state_mediator/state_mediator.dart';

class ReorderItemsHandler
    extends CommandHandler<ReorderItemsCommand, List<ItemModel>> {
  @override
  Future<List<ItemModel>?> handle(
    ReorderItemsCommand command,
    List<ItemModel>? previousState,
  ) async {
    if (previousState == null || previousState.isEmpty) {
      return previousState;
    }

    final items = List<ItemModel>.from(previousState);
    if (command.oldIndex < 0 ||
        command.oldIndex >= items.length ||
        command.newIndex < 0 ||
        command.newIndex >= items.length) {
      return previousState;
    }

    final item = items.removeAt(command.oldIndex);
    items.insert(command.newIndex, item);

    final reorderedItems = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return ItemModel(
        id: item.id,
        name: item.name,
        icon: item.icon,
        order: index + 1,
      );
    }).toList();

    return reorderedItems;
  }
}
