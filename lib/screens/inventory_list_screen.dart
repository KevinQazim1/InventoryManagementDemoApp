import 'package:flutter/material.dart';

import '../data/models/item.dart';
import '../data/services/api_service.dart';
import '../data/exceptions/api_exception.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final _api = ApiService();
  late Future<List<Item>>
  _items; // using future so everything works async with the api service

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

  // multipurposed open form func to except either an item or qr code for the scanner feature
  Future<void> _openForm([Object? arguments]) async {
    final changed = await Navigator.pushNamed(
      context,
      '/item',
      arguments: arguments,
    );
    if (changed == true) _reload();
  }

  // a new scanner method to either open the form to edit or create
  Future<void> _scan() async {
    final sku = await Navigator.pushNamed(context, '/scan') as String?;
    if (sku == null || !mounted) return; // user pressed back without scanning

    try {
      final item = await _api.findBySku(sku);
      if (mounted)
        _openForm(item ?? sku); // existing item → edit, unknown SKU → create
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  // new funcs for the auth feature of logging in and logging out
    // Wipe the navigation history and go to login, so Back can't return to the list
  void _goToLogin() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _logout() async {
    await _api.logout();
    if (mounted) _goToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Manager'),
        actions: [
          // a new button to open the scanner in the app bar
          IconButton(
            onPressed: _scan,
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan QR',
          ),
          IconButton( // new button for logging out
            onPressed: _logout, 
            icon: const Icon(Icons.logout), 
            tooltip: 'Log out'
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // tool bar button for adding an item
        onPressed: () => _openForm(),
        tooltip: 'Add item',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Item>>(
        future: _items,
        builder: (context, snap) {  // snap = Async snapshot, used if dealing with async elements
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {  // modifiing this to adjust to the new login feat, shows login button if not logged in
            final expired = snap.error is ApiException && (snap.error as ApiException).statusCode == 401;
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(expired ? 'Your session expired.' : 'Could not reach the server.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: expired ? _goToLogin : _reload,
                    child: Text(expired ? 'Log in again' : 'Retry'),
                  ),
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
                return ItemTile(
                  // all listed items in the db
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 21,
                    ),
                  ),
                  Text(item.sku),
                  Text(
                    outOfStock
                        ? 'Out of stock'
                        : 'Qty ${item.quantity} · \$${item.price}',
                    style: TextStyle(
                      color: outOfStock
                          ? Theme.of(context).colorScheme.error
                          : null,
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
