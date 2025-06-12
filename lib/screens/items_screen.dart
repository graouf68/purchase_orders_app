import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../models/item.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({Key? key}) : super(key: key);

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final TextEditingController _nameController = TextEditingController();
  List<Item> _items = [];

  Future<void> _loadItems() async {
    final db = await DBHelper.database;
    final maps = await db.query('items');
    setState(() {
      _items = maps.map((e) => Item.fromMap(e)).toList();
    });
  }

  Future<void> _addItem(String name) async {
    final db = await DBHelper.database;
    await db.insert('items', {'name': name});
    _nameController.clear();
    _loadItems();
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأصناف')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'اسم الصنف'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      _addItem(_nameController.text);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_items[index].name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
