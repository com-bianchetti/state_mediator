# state_mediator

A Flutter package that implements the mediator pattern to automate state management, eliminating the need to write repetitive code for handling loading, success, and error states. The package provides a universal controller that manages state lifecycle automatically, allowing views to dispatch commands that are handled by dedicated handler classes.

## Features

- 🚀 **Automatic State Management**: No need to manually manage loading, success, and error states
- 🎯 **Command-Based Architecture**: Dispatch commands from views to update state
- 🔄 **Handler Pattern**: Separate business logic into dedicated handler classes
- 📦 **State Sharing**: Share state between multiple widgets using StateStore
- 🎨 **StateBuilder Widget**: Build UI based on state with loading, error, and success callbacks
- ⚡ **Synchronous & Asynchronous**: Support for both sync and async command execution

## Getting Started

Add `state_mediator` to your `pubspec.yaml`:

```yaml
dependencies:
  state_mediator: ^1.0.0
```

## Usage

### Intro

The `state_mediator` package simplifies state management by automating the process of handling loading, success, and error states. Views dispatch commands that are automatically handled by registered handlers, and the mediator takes care of all state management.

Here's a simple example:

```dart
import 'package:state_mediator/state_mediator.dart';

class GetItemsCommand extends Command<List<ItemModel>> {}

class GetItemsHandler extends CommandHandler<GetItemsCommand, List<ItemModel>> {
  @override
  Future<List<ItemModel>?> handle(
    GetItemsCommand command,
    List<ItemModel>? previousState,
  ) async {
    final items = await repository.getItems();
    return items;
  }
}

void main() {
  StateMediator.registerHandler<GetItemsCommand>(GetItemsHandler());
  runApp(MyApp());
}

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> with Mediator {
  @override
  void initState() {
    super.initState();
    dispatchAsync(GetItemsCommand());
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder<List<ItemModel>>(
      state: state<List<ItemModel>>(),
      onLoading: (context) => CircularProgressIndicator(),
      onError: (error) => Text('Error: $error'),
      onSuccess: (data) => ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) => ListTile(title: Text(data[index].name)),
      ),
    );
  }
}
```

### Commands

Commands are request objects that encapsulate the information needed to update application state. They extend the `Command` class and specify the type of state they update.

#### Basic Command

```dart
class GetItemsCommand extends Command<List<ItemModel>> {
  final String? search;

  GetItemsCommand({this.search});
}
```

#### Command with Direct State Update

For quick state updates that don't require a handler, you can override the `updateState` method:

```dart
class CountCommand extends Command<int> {
  @override
  int? updateState(int? previousState) {
    return (previousState ?? 0) + 1;
  }
}
```

When you dispatch a command with `updateState` implemented, the mediator will use it directly without calling a handler:

```dart
dispatch(CountCommand());
```

#### Custom State ID

By default, states are identified by their type. If you need multiple states of the same type, you can specify a custom `stateId`:

```dart
class UserProfileCommand extends Command<User> {
  @override
  String get stateId => 'user_profile';
}
```

### Handlers

Handlers contain the business logic for processing commands. They extend `CommandHandler` and implement the `handle` method.

#### Basic Handler

```dart
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
```

#### Handler with Previous State

Handlers receive the previous state as a parameter, allowing you to update it incrementally:

```dart
class SaveItemHandler extends CommandHandler<SaveItemCommand, List<ItemModel>> {
  final IItemsRepository itemsRepository;

  SaveItemHandler({required this.itemsRepository});

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
```

#### Registering Handlers

All handlers must be registered before using the mediator:

```dart
void main() {
  final repository = MockItemsRepository();
  
  StateMediator.registerHandler<GetItemsCommand>(
    GetItemsHandler(itemsRepository: repository),
  );
  StateMediator.registerHandler<SaveItemCommand>(
    SaveItemHandler(itemsRepository: repository),
  );
  
  runApp(MyApp());
}
```

### Mediator

The `Mediator` mixin is used in stateful widgets to manage state. It provides methods to dispatch commands and access state.

#### Using the Mediator Mixin

```dart
class _MyScreenState extends State<MyScreen> with Mediator {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dispatchAsync(GetItemsCommand());
    });
  }

  Future<void> _loadItems() async {
    await dispatchAsync(GetItemsCommand());
  }

  Future<void> _addItem() async {
    await dispatchAsync(
      SaveItemCommand(name: 'Item', icon: '📦'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StateBuilder<List<ItemModel>>(
        state: state<List<ItemModel>>(),
        onSuccess: (data) => ListView(...),
      ),
    );
  }
}
```

#### Dispatching Commands

**Asynchronous Dispatch**: Use `dispatchAsync` for commands that require async operations. The mediator automatically sets the state to loading before execution:

```dart
await dispatchAsync(GetItemsCommand());
```

**Synchronous Dispatch**: Use `dispatch` for commands that update state directly (using `updateState` method) or for quick synchronous operations:

```dart
dispatch(CountCommand());
```

#### Accessing State

Use the `state` getter to access state by type or custom ID:

```dart
state<List<ItemModel>>()
state<int>('custom_count_id')
```

#### Error Handling

Configure a custom error handler for the mediator:

```dart
@override
void initState() {
  super.initState();
  configMediator(
    errorHandler: (error, stackTrace) {
      return Result.error('Custom error: $error');
    },
  );
}
```

You can also set a global error handler:

```dart
StateMediator.errorHandler = (error, stackTrace) {
  return Result.error('Global error: $error');
};
```

### StateBuilder

The `StateBuilder` widget builds UI based on the current state, automatically handling loading, error, and success states.

#### Using StateBuilder with Callbacks

```dart
StateBuilder<List<ItemModel>>(
  state: state<List<ItemModel>>(),
  onLoading: (context) => Center(
    child: CircularProgressIndicator(),
  ),
  onError: (error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Error: $error'),
        ElevatedButton(
          onPressed: () => dispatchAsync(GetItemsCommand()),
          child: Text('Retry'),
        ),
      ],
    ),
  ),
  onSuccess: (data) {
    if (data.isEmpty) {
      return Center(child: Text('No items yet. Add one to get started!'));
    }
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(data[index].name),
      ),
    );
  },
)
```

#### Using StateBuilder with Custom Builder

For more control, use the `builder` callback:

```dart
StateBuilder<int>(
  state: state<int>(),
  builder: (isLoading, data, error) {
    if (isLoading) {
      return CircularProgressIndicator();
    }
    if (error != null) {
      return Text('Error: $error');
    }
    return Text('Count: ${data ?? 0}');
  },
)
```

### StateStore

`StateStore` allows you to share state between multiple widgets and mediators. This is useful for maintaining state across navigation or between different parts of your app.

#### Creating a StateStore

```dart
class SharedState extends StateStore {
  SharedState({super.state});
}
```

#### Using StateStore with Dependency Injection

```dart
import 'package:get_it/get_it.dart';

void main() {
  GetIt.instance.registerSingleton<SharedState>(SharedState());
  runApp(MyApp());
}

class _Page01State extends State<Page01> with Mediator {
  @override
  void initState() {
    super.initState();
    initStateStore(GetIt.instance.get<SharedState>());
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder<int>(
      state: state<int>(),
      builder: (isLoading, data, error) => Text('count: ${data ?? 0}'),
    );
  }
}

class _Page02State extends State<Page02> with Mediator {
  @override
  void initState() {
    super.initState();
    initStateStore(GetIt.instance.get<SharedState>());
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder<int>(
      state: state<int>(),
      builder: (isLoading, data, error) => Text('count: ${data ?? 0}'),
    );
  }
}
```

Both `Page01` and `Page02` will share the same state. When you dispatch a command that updates the `int` state in one page, the other page will automatically reflect the change.

#### Important Notes about StateStore

- When using `initStateStore`, the mediator will not dispose of the state when the widget is disposed
- The `StateStore` should be disposed manually when it's no longer needed (e.g., when the app closes)
- All mediators using the same store will share the same state map

## Additional Information

For more examples, check out the `/example` folder in this package.

### Result States

The `Result` class represents the state of a command execution:

- **Loading**: `Result.loading([previousData])` - Command is being processed
- **Success**: `Result.success(data)` - Command completed successfully
- **Error**: `Result.error(message)` - Command failed with an error
- **Empty**: `Result.empty()` - Initial state with no data

The mediator automatically manages these states when you dispatch commands.

### Best Practices

1. **Register all handlers before using the mediator** - Handlers must be registered in your app's initialization (typically in `main()`)

2. **Use `dispatchAsync` for async operations** - This ensures the loading state is properly set

3. **Use `dispatch` for synchronous updates** - Use this for commands with `updateState` or quick synchronous operations

4. **Keep handlers focused** - Each handler should handle one specific command type

5. **Use StateStore for shared state** - When state needs to be shared across multiple screens or widgets

6. **Handle errors appropriately** - Configure error handlers to provide meaningful error messages to users
