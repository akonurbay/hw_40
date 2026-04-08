import 'package:flutter/material.dart';
import 'screens/list_screen.dart';
import 'repositories/items_repository.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hw_40',
      routes: {
        '/': (context) => ListScreen(repository: InMemoryItemsRepository()),
      },
    );
  }
}
