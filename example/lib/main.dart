import 'package:example/handlers/delete_item_handler.dart';
import 'package:example/commands/items_command.dart';
import 'package:example/handlers/get_items_handler.dart';
import 'package:example/handlers/reorder_items_handler.dart';
import 'package:example/handlers/save_items_handler.dart';
import 'package:example/repositories/mock_items_repository.dart';
import 'package:example/screens/items_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:state_mediator/state_mediator.dart';

void main() {
  final repository = MockItemsRepository();
  StateMediator.registerHandler<GetItemsCommand>(
    GetItemsHandler(itemsRepository: repository),
  );
  StateMediator.registerHandler<SaveItemCommand>(
    SaveItemsHandler(itemsRepository: repository),
  );
  StateMediator.registerHandler<DeleteItemCommand>(
    DeleteItemHandler(itemsRepository: repository),
  );
  StateMediator.registerHandler<ReorderItemsCommand>(ReorderItemsHandler());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ItemsListScreen(),
    );
  }
}
