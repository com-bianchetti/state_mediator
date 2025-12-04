import 'package:example/commands/items_command.dart';
import 'package:example/models/item_model.dart';
import 'package:flutter/material.dart';
import 'package:state_mediator/state_mediator.dart';

class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen({super.key});

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> with Mediator {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dispatchAsync(GetItemsCommand());
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    await dispatchAsync(GetItemsCommand());
  }

  Future<void> _addItem() async {
    if (_formKey.currentState!.validate()) {
      await dispatchAsync(
        SaveItemCommand(name: _nameController.text, icon: _iconController.text),
      );
      _nameController.clear();
      _iconController.clear();
    }
  }

  Future<void> _deleteItem(String id) async {
    await dispatchAsync(DeleteItemCommand(id: id));
  }

  Future<void> _reorderItems(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    await dispatch(ReorderItemsCommand(oldIndex: oldIndex, newIndex: newIndex));
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _iconController,
                decoration: const InputDecoration(
                  labelText: 'Icon',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an icon';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _addItem();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadItems,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ValueListenableBuilder<Result>(
        valueListenable: state<List<ItemModel>>(),
        builder: (context, result, _) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${result.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadItems,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final items = result.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text('No items yet. Add one to get started!'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: items.length,
                  onReorder: (oldIndex, newIndex) {
                    _reorderItems(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      key: ValueKey(item.id),
                      leading: CircleAvatar(
                        child: Text(item.icon.isNotEmpty ? item.icon[0] : '?'),
                      ),
                      title: Text(item.name),
                      subtitle: Text('Order: ${item.order}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.redAccent,
                        iconSize: 21,
                        onPressed: () => _deleteItem(item.id),
                        tooltip: 'Delete',
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total changes:'),
                  ValueListenableBuilder(
                    valueListenable: state<int>(),
                    builder: (context, value, _) => Text('${value.data ?? 0}'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
