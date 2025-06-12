import 'package:flutter/material.dart';
import 'purchase_order_details_screen.dart';
import '../db_helper.dart';
import '../models/purchase_order.dart';
import 'package:intl/intl.dart';

class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  List<PurchaseOrder> _orders = [];

  Future<void> _loadOrders() async {
    final db = await DBHelper.database;
    final maps = await db.query('purchase_orders');
    setState(() {
      _orders = maps.map((e) => PurchaseOrder.fromMap(e)).toList();
    });
  }

  Future<void> _addOrder() async {
    final db = await DBHelper.database;
    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int newId = await db.insert('purchase_orders', {
      'vendorId': 1,
      'date': now,
    });
    _loadOrders();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PurchaseOrderDetailsScreen(orderId: newId),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أوامر التوريد')),
      body: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return ListTile(
            title: Text('أمر #${order.id}'),
            subtitle: Text('تاريخ: ${order.date}'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PurchaseOrderDetailsScreen(orderId: order.id!),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addOrder,
        child: const Icon(Icons.add),
      ),
    );
  }
}
