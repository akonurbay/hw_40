import 'package:flutter/material.dart';
import '../models/item.dart';
import '../repositories/items_repository.dart';

enum ViewState { idle, loading, loaded, error }

class ItemsViewModel extends ChangeNotifier {
  final ItemsRepository repository;

  ItemsViewModel({required this.repository});

  ViewState state = ViewState.idle;
  List<Item> items = [];
  String? errorMessage;

  Future<void> loadItems() async {
    state = ViewState.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final fetched = await repository.fetchItems();
      items = fetched;
      state = ViewState.loaded;
    } catch (e) {
      state = ViewState.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> addItem(String text) async {
    state = ViewState.loading;
    notifyListeners();
    try {
      final item = await repository.addItem(text);
      items.insert(0, item);
      state = ViewState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      state = ViewState.error;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}