import 'dart:async';

import 'package:example/commands/items_command.dart';
import 'package:example/models/item_model.dart';
import 'package:example/repositories/mock_items_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:state_mediator/state_mediator.dart';

class SaveItemsHandler
    extends CommandHandler<SaveItemCommand, List<ItemModel>> {
  final IItemsRepository itemsRepository;

  SaveItemsHandler({required this.itemsRepository});

  @override
  Future<List<ItemModel>?> handle(
    SaveItemCommand command,
    List<ItemModel>? previousState,
  ) async {
    final items = previousState ?? [];

    if (command.id == null) {
      final newItem = await itemsRepository.createItem(
        ItemModel(id: Uuid().v4(), name: command.name, icon: command.icon),
      );
      items.add(newItem);
    } else {
      final updatedItem = await itemsRepository.updateItem(
        ItemModel(id: command.id!, name: command.name, icon: command.icon),
      );
      final index = items.indexWhere((element) => element.id == command.id);
      if (index != -1) {
        items[index] = updatedItem;
      }
    }
    return items;
  }
}
