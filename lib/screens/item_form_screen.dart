import 'package:flutter/material.dart';

import '../data/models/item.dart';
import '../data/services/api_service.dart';

// One screen for both create and edit: the route argument decides which
class ItemFormScreen extends StatefulWidget {
  const ItemFormScreen({super.key});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _description = TextEditingController();
  final _quantity = TextEditingController(text: '0');
  final _price = TextEditingController();
  final _location = TextEditingController();

  Item? _item; // null = creating a new item
  bool _loaded = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return; // this can run more than once, only fill the fields the first time
    _loaded = true;

    _item = ModalRoute.of(context)!.settings.arguments as Item?;
    final item = _item;
    if (item != null) {
      _name.text = item.name;
      _sku.text = item.sku;
      _description.text = item.description;
      _quantity.text = '${item.quantity}';
      _price.text = item.price;
      _location.text = item.location;
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _sku, _description, _quantity, _price, _location]) {
      c.dispose();
    }
    super.dispose();
  }



  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = Item(
      id: _item?.id,
      name: _name.text.trim(),
      sku: _sku.text.trim(),
      description: _description.text.trim(),
      quantity: int.parse(_quantity.text),
      price: _price.text.trim(),
      location: _location.text.trim(),
    );

    try {
      _item == null ? await _api.createItem(item) : await _api.updateItem(item);
      if (mounted) Navigator.pop(context, true); // true tells the list to reload
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('${_item!.name} will be removed permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _api.deleteItem(_item!.id!);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_item == null ? 'New item' : 'Edit item'),
        actions: [
          if (_item != null)
            IconButton(onPressed: _saving ? null : _delete, icon: const Icon(Icons.delete), tooltip: 'Delete'),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: _required,
            ),
            TextFormField(
              controller: _sku,
              decoration: const InputDecoration(labelText: 'SKU'),
              validator: _required,
            ),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextFormField(
              controller: _quantity,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return (n == null || n < 0) ? 'Enter a whole number, 0 or more' : null;
              },
            ),
            TextFormField(
              controller: _price,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(v?.trim() ?? '') ? null : 'Enter a price like 9.99',    // using regex to check if the entered number for price is valid
            ),
            TextFormField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving…' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}