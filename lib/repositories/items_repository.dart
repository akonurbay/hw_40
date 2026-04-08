import 'dart:async';
import '../models/item.dart';

abstract class ItemsRepository {
  Future<List<Item>> fetchItems();
  Future<Item> addItem(String text);
}

class InMemoryItemsRepository implements ItemsRepository {
  final List<Item> _items = [];
  bool simulateFetchError = false;
  bool simulateAddError = false;
  Duration artificialDelay = const Duration(milliseconds: 300);

  @override
  Future<List<Item>> fetchItems() async {
    await Future.delayed(artificialDelay);
    if (simulateFetchError) throw Exception('fetch error');
    // return a copy
    return List.unmodifiable(_items);
  }

  @override
  Future<Item> addItem(String text) async {
    await Future.delayed(artificialDelay);
    if (simulateAddError) throw Exception('add error');
    final item = Item(id: DateTime.now().millisecondsSinceEpoch.toString(), text: text);
    _items.insert(0, item);
    return item;
  }
}