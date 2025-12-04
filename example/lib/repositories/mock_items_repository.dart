import 'package:example/models/item_model.dart';

abstract class IItemsRepository {
  Future<List<ItemModel>> getItems();
  Future<ItemModel> createItem(ItemModel item);
  Future<ItemModel> updateItem(ItemModel item);
  Future<void> deleteItem(String id);
}

class MockItemsRepository implements IItemsRepository {
  final List<ItemModel> items = [
    ItemModel(id: '1', name: 'Item 1', icon: 'icon1', order: 1),
    ItemModel(id: '2', name: 'Item 2', icon: 'icon2', order: 2),
    ItemModel(id: '3', name: 'Item 3', icon: 'icon3', order: 3),
  ];

  @override
  Future<List<ItemModel>> getItems() async {
    return items;
  }

  @override
  Future<ItemModel> createItem(ItemModel item) async {
    items.add(item);
    return item;
  }

  @override
  Future<ItemModel> updateItem(ItemModel item) async {
    items
        .firstWhere((element) => element.id == item.id)
        .copyWith(name: item.name, icon: item.icon);
    return item;
  }

  @override
  Future<void> deleteItem(String id) async {
    items.removeWhere((element) => element.id == id);
  }
}
