import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_mediator/state_mediator.dart';

class TestData {
  final String value;
  TestData(this.value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestData &&
          runtimeType == other.runtimeType &&
          value == other.value;
  @override
  int get hashCode => value.hashCode;
}

class TestCommand extends Command<TestData> {
  final String value;
  TestCommand(this.value);
}

class TestCommandWithId extends Command<TestData> {
  final String value;
  final String customId;
  TestCommandWithId(this.value, this.customId);
  @override
  String? get stateId => customId;
}

class TestCommandWithUpdateState extends Command<TestData> {
  final String value;
  TestCommandWithUpdateState(this.value);
  @override
  TestData? updateState(TestData? previousState) {
    return TestData(value);
  }
}

class TestCommandWithUpdateStateNull extends Command<TestData> {
  TestCommandWithUpdateStateNull();
  @override
  TestData? updateState(TestData? previousState) {
    return null;
  }
}

class TestCommandWithPreviousState extends Command<TestData> {
  final String value;
  TestCommandWithPreviousState(this.value);
  @override
  TestData? updateState(TestData? previousState) {
    return TestData('${previousState?.value ?? 'none'}_$value');
  }
}

class TestHandler extends CommandHandler<TestCommand, TestData> {
  final String resultValue;
  final bool shouldThrow;
  TestHandler({this.resultValue = 'handler_result', this.shouldThrow = false});
  @override
  Future<TestData?> handle(TestCommand command, TestData? previousState) async {
    if (shouldThrow) {
      throw Exception('Handler error');
    }
    await Future.delayed(const Duration(milliseconds: 10));
    return TestData(resultValue);
  }
}

class TestHandlerWithId extends CommandHandler<TestCommandWithId, TestData> {
  final String resultValue;
  TestHandlerWithId({this.resultValue = 'handler_result'});
  @override
  Future<TestData?> handle(
    TestCommandWithId command,
    TestData? previousState,
  ) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return TestData(resultValue);
  }
}

class TestHandlerReturnsNull extends CommandHandler<TestCommand, TestData> {
  @override
  Future<TestData?> handle(TestCommand command, TestData? previousState) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return null;
  }
}

class TestStore extends StateStore {
  TestStore({super.state});
}

class TestWidget extends StatefulWidget {
  final String? stateId;
  final Command? initialCommand;
  final bool useAsync;
  const TestWidget({
    super.key,
    this.stateId,
    this.initialCommand,
    this.useAsync = true,
  });
  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> with Mediator {
  @override
  void initState() {
    super.initState();
    if (widget.initialCommand != null) {
      if (widget.useAsync) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          dispatchAsync(widget.initialCommand!);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          dispatch(widget.initialCommand!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateNotifier = widget.stateId != null
        ? state<TestData>(widget.stateId)
        : state<TestData>();
    return StateBuilder<TestData>(
      state: stateNotifier,
      onLoading: (context) => const Text('Loading'),
      onError: (error) => Text('Error: $error'),
      onSuccess: (data) => Text('Success: ${data.value}'),
    );
  }
}

void main() {
  setUp(() {
    StateMediator.errorHandler = (e, stackTrace) => Result.error(e.toString());
  });

  group('Mediator state getter', () {
    testWidgets('creates state with default id when accessed', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier = widgetState.state<TestData>();
      expect(stateNotifier.value.isLoading, true);
      expect(stateNotifier.value.data, null);
    });

    testWidgets('creates state with custom id when accessed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TestWidget(stateId: 'custom_id')),
      );
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier = widgetState.state<TestData>('custom_id');
      expect(stateNotifier.value.isLoading, true);
      expect(stateNotifier.value.data, null);
    });

    testWidgets('returns same state notifier for same id', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier1 = widgetState.state<TestData>();
      final stateNotifier2 = widgetState.state<TestData>();
      expect(identical(stateNotifier1, stateNotifier2), true);
    });

    testWidgets('returns different state notifiers for different ids', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier1 = widgetState.state<TestData>('id1');
      final stateNotifier2 = widgetState.state<TestData>('id2');
      expect(identical(stateNotifier1, stateNotifier2), false);
    });
  });

  group('Mediator dispatchAsync', () {
    testWidgets('updates state to loading then success when handler succeeds', (
      tester,
    ) async {
      StateMediator.registerHandler<TestCommand>(TestHandler());
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(initialCommand: TestCommand('test'), useAsync: true),
        ),
      );
      await tester.pump();
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier = widgetState.state<TestData>();
      expect(stateNotifier.value.isLoading, true);
      expect(find.text('Loading'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(stateNotifier.value.isSuccess, true);
      expect(stateNotifier.value.data?.value, 'handler_result');
      expect(find.text('Success: handler_result'), findsOneWidget);
    });

    testWidgets('updates state to error when handler throws', (tester) async {
      StateMediator.registerHandler<TestCommand>(
        TestHandler(shouldThrow: true),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(initialCommand: TestCommand('test'), useAsync: true),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier = widgetState.state<TestData>();
      expect(stateNotifier.value.isSuccess, false);
      expect(stateNotifier.value.error, isNotNull);
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('preserves previous data when loading', (tester) async {
      StateMediator.registerHandler<TestCommand>(TestHandler());
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(initialCommand: TestCommand('test'), useAsync: true),
        ),
      );
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier = widgetState.state<TestData>();
      stateNotifier.value = Result.success(TestData('previous'));
      await tester.pump();
      widgetState.dispatchAsync(TestCommand('test'));
      await tester.pump();
      expect(stateNotifier.value.isLoading, true);
      expect(stateNotifier.value.data?.value, 'previous');
      await tester.pumpAndSettle();
    });

    testWidgets('does not update state when handler returns null', (
      tester,
    ) async {
      StateMediator.registerHandler<TestCommand>(TestHandlerReturnsNull());
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(initialCommand: TestCommand('test'), useAsync: true),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier = widgetState.state<TestData>();
      expect(stateNotifier.value.isLoading, true);
      expect(stateNotifier.value.data, null);
      await tester.pumpAndSettle();
    });

    testWidgets('uses custom error handler when configured', (tester) async {
      StateMediator.registerHandler<TestCommand>(
        TestHandler(shouldThrow: true),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(initialCommand: TestCommand('test'), useAsync: true),
        ),
      );
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      widgetState.configMediator(
        errorHandler: (e, stackTrace) => Result.error('Custom error'),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      final stateNotifier = widgetState.state<TestData>();
      expect(stateNotifier.value.error, 'Exception: Handler error');
    });

    testWidgets('uses command with custom stateId', (tester) async {
      StateMediator.registerHandler<TestCommandWithId>(TestHandlerWithId());
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            stateId: 'custom_state',
            initialCommand: TestCommandWithId('test', 'custom_state'),
            useAsync: true,
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier = widgetState.state<TestData>('custom_state');
      expect(stateNotifier.value.isSuccess, true);
      expect(stateNotifier.value.data?.value, 'handler_result');
    });
  });

  group('Mediator dispatch (sync)', () {
    testWidgets(
      'updates state to success without loading when handler succeeds',
      (tester) async {
        StateMediator.registerHandler<TestCommand>(TestHandler());
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              initialCommand: TestCommand('test'),
              useAsync: false,
            ),
          ),
        );
        await tester.pump();
        await tester.pumpAndSettle();
        final widgetState = tester.state<_TestWidgetState>(
          find.byType(TestWidget),
        );
        final stateNotifier = widgetState.state<TestData>();
        expect(stateNotifier.value.isSuccess, true);
        expect(stateNotifier.value.data?.value, 'handler_result');
        expect(find.text('Success: handler_result'), findsOneWidget);
      },
    );

    testWidgets('updates state to error when handler throws in sync dispatch', (
      tester,
    ) async {
      StateMediator.registerHandler<TestCommand>(
        TestHandler(shouldThrow: true),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            initialCommand: TestCommand('test'),
            useAsync: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier = widgetState.state<TestData>();
      expect(stateNotifier.value.isSuccess, false);
      expect(stateNotifier.value.error, isNotNull);
    });
  });

  group('Mediator updateState', () {
    testWidgets('updates state directly when updateState returns value', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            initialCommand: TestCommandWithUpdateState('direct_update'),
            useAsync: true,
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier = widgetState.state<TestData>();
      expect(stateNotifier.value.isSuccess, true);
      expect(stateNotifier.value.data?.value, 'direct_update');
      expect(find.text('Success: direct_update'), findsOneWidget);
    });

    testWidgets('uses previous state in updateState', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier = widgetState.state<TestData>();
      stateNotifier.value = Result.success(TestData('previous'));
      widgetState.dispatchAsync(TestCommandWithPreviousState('new'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(stateNotifier.value.data?.value, 'previous_new');
    });
  });

  group('Mediator initStateStore', () {
    testWidgets('initializes mediator with store state', (tester) async {
      final store = TestStore();
      final existingState = ValueNotifier<Result>(
        Result.success(TestData('store_data')),
      );
      store.state['TestData'] = existingState;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return const TestWidget();
            },
          ),
        ),
      );
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      widgetState.initStateStore(store);
      await tester.pump();
      final stateNotifier = widgetState.state<TestData>();
      expect(identical(stateNotifier, existingState), true);
      expect(stateNotifier.value.data?.value, 'store_data');
    });

    testWidgets('clears previous state when initializing with store', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier1 = widgetState.state<TestData>('id1');
      stateNotifier1.value = Result.success(TestData('data1'));
      final store = TestStore();
      widgetState.initStateStore(store);
      await tester.pump();
      final stateNotifier2 = widgetState.state<TestData>('id1');
      expect(stateNotifier2.value.data, null);
    });

    testWidgets(
      'does not dispose state when initialized with store on dispose',
      (tester) async {
        final store = TestStore();
        final existingState = ValueNotifier<Result>(
          Result.success(TestData('store_data')),
        );
        store.state['TestData'] = existingState;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return const TestWidget();
              },
            ),
          ),
        );
        final widgetState = tester.state<_TestWidgetState>(
          find.byType(TestWidget),
        );
        widgetState.initStateStore(store);
        await tester.pump();
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        expect(existingState.value.data?.value, 'store_data');
      },
    );
  });

  group('Mediator multiple states', () {
    testWidgets('manages multiple states independently', (tester) async {
      StateMediator.registerHandler<TestCommand>(
        TestHandler(resultValue: 'result1'),
      );
      StateMediator.registerHandler<TestCommandWithId>(
        TestHandlerWithId(resultValue: 'result2'),
      );
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier1 = widgetState.state<TestData>('state1');
      final stateNotifier2 = widgetState.state<TestData>('state2');
      widgetState.dispatchAsync(TestCommand('test1'));
      await tester.pump();
      stateNotifier1.value = Result.success(TestData('data1'));
      widgetState.dispatchAsync(TestCommandWithId('test2', 'state2'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(stateNotifier1.value.data?.value, 'data1');
      expect(stateNotifier2.value.data?.value, 'result2');
    });
  });

  group('Mediator error handling', () {
    testWidgets('uses default error handler when no custom handler set', (
      tester,
    ) async {
      StateMediator.registerHandler<TestCommand>(
        TestHandler(shouldThrow: true),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(initialCommand: TestCommand('test'), useAsync: true),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      final widgetState = tester.state<_TestWidgetState>(
        find.byType(TestWidget),
      );
      final stateNotifier = widgetState.state<TestData>();
      expect(stateNotifier.value.isSuccess, false);
      expect(stateNotifier.value.error, isNotNull);
      expect(stateNotifier.value.error, contains('Exception'));
    });
  });
}
