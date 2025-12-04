import 'package:example/models/item_model.dart';
import 'package:state_mediator/components/command.dart';

class GetItemsCommand extends Command<List<ItemModel>> {
  final String? search;

  GetItemsCommand({this.search});
}

class DeleteItemCommand extends Command<List<ItemModel>> {
  final String id;

  DeleteItemCommand({required this.id});
}

class SaveItemCommand extends Command<List<ItemModel>> {
  final String name;
  final String icon;
  final String? id;

  SaveItemCommand({required this.name, required this.icon, this.id});
}

class ReorderItemsCommand extends Command<List<ItemModel>> {
  final int oldIndex;
  final int newIndex;

  ReorderItemsCommand({required this.oldIndex, required this.newIndex});
}
