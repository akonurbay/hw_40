import 'package:flutter/material.dart';
import '../repositories/items_repository.dart';
import '../view_models/items_view_model.dart';
import 'detail_screen.dart';
import '../models/item.dart';

class ListScreen extends StatefulWidget {
  final ItemsRepository repository;
  const ListScreen({super.key, required this.repository});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late final ItemsViewModel vm;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    vm = ItemsViewModel(repository: widget.repository);
    // start idle: require user to press Load to demonstrate empty->loading->items
  }

  @override
  void dispose() {
    _controller.dispose();
    vm.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    _controller.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add item'),
        content: TextField(
          key: const Key('add_text_field'),
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Text'),
        ),
        actions: [
          TextButton(
            key: const Key('add_cancel_button'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('add_confirm_button'),
            onPressed: () async {
              final text = _controller.text.trim();
              if (text.isEmpty) return;
              Navigator.of(context).pop();
              final success = await vm.addItem(text);
              if (!success) {
                // show snackbar on error
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(key: Key('snackbar_error'), content: Text('Failed to add item')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (vm.state) {
      case ViewState.idle:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No items', key: Key('list_empty')),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('load_button'),
              onPressed: () => vm.loadItems(),
              child: const Text('Load'),
            ),
          ],
        );
      case ViewState.loading:
        return const Center(key: Key('list_loading'), child: CircularProgressIndicator());
      case ViewState.loaded:
        if (vm.items.isEmpty) {
          return const Center(child: Text('No items', key: Key('list_empty')));
        }
        return ListView.builder(
          key: const Key('list_items'),
          itemCount: vm.items.length,
          itemBuilder: (context, index) {
            final Item item = vm.items[index];
            return ListTile(
              key: Key('item_tile_$index'),
              title: Text(item.text),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(item: item),
                  ),
                );
              },
            );
          },
        );
      case ViewState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${vm.errorMessage}', key: const Key('list_error')),
              const SizedBox(height: 12),
              ElevatedButton(
                key: const Key('retry_button'),
                onPressed: () => vm.loadItems(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      body: AnimatedBuilder(
        animation: vm,
        builder: (_, __) => _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_button'),
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}