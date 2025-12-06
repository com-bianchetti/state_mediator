import 'package:example/commands/count_command.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:state_mediator/components/mediator.dart';
import 'package:state_mediator/components/state.dart';
import 'package:state_mediator/components/store.dart';

class SharedState extends StateStore {}

class Page01 extends StatefulWidget {
  const Page01({super.key});

  @override
  State<Page01> createState() => _Page01State();
}

class _Page01State extends State<Page01> with Mediator {
  @override
  void initState() {
    super.initState();
    initStateStore(GetIt.instance.get<SharedState>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page 01')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StateBuilder(
              state: state<int>(),
              builder: (isLoading, data, error) => Text('count: ${data ?? 0}'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                dispatch(CountCommand());
              },
              child: const Text('Increment'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Page02()),
                );
              },
              child: const Text('Page 02'),
            ),
          ],
        ),
      ),
    );
  }
}

class Page02 extends StatefulWidget {
  const Page02({super.key});

  @override
  State<Page02> createState() => _Page02State();
}

class _Page02State extends State<Page02> with Mediator {
  @override
  void initState() {
    super.initState();
    initStateStore(GetIt.instance.get<SharedState>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page 02')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StateBuilder(
              state: state<int>(),
              builder: (isLoading, data, error) => Text('count: ${data ?? 0}'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                dispatch(CountCommand());
              },
              child: const Text('Increment'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Page 01'),
            ),
          ],
        ),
      ),
    );
  }
}
