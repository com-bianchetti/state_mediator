import 'dart:async';

import 'package:example/commands/items_command.dart';
import 'package:example/models/item_model.dart';
import 'package:example/repositories/mock_items_repository.dart';
import 'package:state_mediator/state_mediator.dart';

class GetItemsHandler extends CommandHandler<GetItemsCommand, List<ItemModel>> {
  final IItemsRepository itemsRepository;

  GetItemsHandler({required this.itemsRepository});

  @override
  Future<List<ItemModel>?> handle(
    GetItemsCommand command,
    List<ItemModel>? previousState,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    final list = await itemsRepository.getItems();
    return [...list];
  }
}
