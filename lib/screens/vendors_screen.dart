import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../models/vendor.dart';
import 'package:sqflite/sqflite.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({Key? key}) : super(key: key);

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  final TextEditingController _nameController = TextEditingController();
  List<Vendor> _vendors = [];

  Future<void> _loadVendors() async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('vendors');
    setState(() {
      _vendors = maps.map((map) => Vendor.fromMap(map)).toList();
    });
  }

  Future<void> _addVendor(String name) async {
    final db = await DBHelper.database;
    await db.insert('vendors', {'name': name});
    _nameController.clear();
    _loadVendors();
  }

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الموردين')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'اسم المورد'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      _addVendor(_nameController.text);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _vendors.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_vendors[index].name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
