import 'dart:async';

import 'package:example/commands/items_command.dart';
import 'package:example/models/item_model.dart';
import 'package:example/repositories/mock_items_repository.dart';
import 'package:state_mediator/state_mediator.dart';

class DeleteItemHandler
    extends CommandHandler<DeleteItemCommand, List<ItemModel>> {
  final IItemsRepository itemsRepository;

  DeleteItemHandler({required this.itemsRepository});

  @override
  Future<List<ItemModel>?> handle(
    DeleteItemCommand command,
    List<ItemModel>? previousState,
  ) async {
    await itemsRepository.deleteItem(command.id);
    return previousState?.where((element) => element.id != command.id).toList();
  }
}
