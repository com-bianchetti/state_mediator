import 'package:example/commands/count_command.dart';
import 'package:example/commands/items_command.dart';
import 'package:example/models/item_model.dart';
import 'package:example/screens/shared_state.dart';
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
      dispatch(CountCommand());
      _nameController.clear();
      _iconController.clear();
    }
  }

  Future<void> _deleteItem(String id) async {
    await dispatchAsync(DeleteItemCommand(id: id));
    dispatch(CountCommand());
  }

  Future<void> _reorderItems(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    dispatch(ReorderItemsCommand(oldIndex: oldIndex, newIndex: newIndex));
    dispatch(CountCommand());
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
                // ignore: use_build_context_synchronously
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
            icon: const Icon(Icons.numbers),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Page01()),
              );
            },
            tooltip: 'Settings',
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadItems,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: StateBuilder<List<ItemModel>>(
        state: state<List<ItemModel>>(),
        onLoading: (context) =>
            const Center(child: CircularProgressIndicator()),
        onError: (error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Error: $error')],
          ),
        ),
        onSuccess: (data) {
          final items = data;

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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total changes:'),
                    StateBuilder<int>(
                      state: state<int>(),
                      builder: (isLoading, data, error) => Text('${data ?? 0}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 130),
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
