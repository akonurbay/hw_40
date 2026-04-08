import 'package:flutter/material.dart';
import '../models/item.dart';

class DetailScreen extends StatelessWidget {
  final Item item;
  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: Center(
        key: const Key('detail_screen'),
        child: Text(item.text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}