import 'package:flutter/material.dart';

import '../data/models/item.dart';
import '../data/services/api_service.dart';
import '../data/models/item.dart';
import '../data/services/api_service.dart';
import 'item_form_screen.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {

  final _api = ApiService();
  late Future<List<Item>> _items; // using future so everything works async with the api service

  @override
  void initState() {
    super.initState();
    _items = _api.getItems();
  }

  Future<void> _reload() async {
    setState(() {
      _items = _api.getItems();
    });
    await _items;
  }

  Future<void> _openForm([Item? item]) async {
    final changed = await Navigator.pushNamed(context, '/item', arguments: item);
    if (changed == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Manager')),
      floatingActionButton: FloatingActionButton(   // tool bar button for adding an item
        onPressed: () => _openForm(),
        tooltip: 'Add item',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Item>>(
        future: _items,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not reach the server. Please refresh'),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _reload, child: const Text('Retry')),
                ],
              ),
            );
          }
          final items = snap.data!;
          // a check that sees if there are no items in the list and displays to the user to add one. better UX
          if (items.isEmpty) {
            return const Center(child: Text('No items yet. Tap + to add one.'));
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return ItemTile(  // all listed items in the db
                  onTap: () => _openForm(item),
                  item: item,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// A custom tappable item row
class ItemTile extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Item item;

  const ItemTile({
    super.key,
    required this.onTap,
    this.onLongPress,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = item.quantity == 0;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Ink(
            width: double.infinity,
            height: 120,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 21),
                  ),
                  Text(item.sku),
                  Text(
                    outOfStock ? 'Out of stock' : 'Qty ${item.quantity} · \$${item.price}',
                    style: TextStyle(
                      color: outOfStock ? Theme.of(context).colorScheme.error : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 5),
        ],
      ),
    );
  }
}
