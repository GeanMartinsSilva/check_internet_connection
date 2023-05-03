import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionNotifier extends InheritedNotifier<ValueNotifier<bool>> {
  const ConnectionNotifier({
    super.key,
    required super.notifier,
    required super.child,
  });

  static ValueNotifier<bool> of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ConnectionNotifier>()!
        .notifier!;
  }
}

// Modificando o tempo de espera para verificação
final internetConnectionChecker = InternetConnectionChecker.createInstance(
  checkTimeout: const Duration(seconds: 1),
  checkInterval: const Duration(seconds: 1),
  // Nessa lista de endereços é possivel inserir outras conexões na qual eu gostaria de fazer verificações
  // Como por exemplo verificar a saúde da minha API
  //addresses: [],
);

void main() async {
  final hasConnection = await internetConnectionChecker.hasConnection;
  runApp(
    ConnectionNotifier(
      notifier: ValueNotifier(hasConnection),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<InternetConnectionStatus> listener;
  @override
  void initState() {
    super.initState();
    listener = internetConnectionChecker.onStatusChange.listen((status) {
      final notifier = ConnectionNotifier.of(context);
      notifier.value =
          status == InternetConnectionStatus.connected ? true : false;
    });
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internet Connect Checker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final hasConnection = ConnectionNotifier.of(context).value;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Icon(
          hasConnection ? Icons.check_box : Icons.error,
          size: 100,
        ),
      ),
    );
  }
}
