import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../models/purchase_order.dart';
import '../models/item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class PurchaseOrderDetailsScreen extends StatefulWidget {
  final int orderId;
  const PurchaseOrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<PurchaseOrderDetailsScreen> createState() => _PurchaseOrderDetailsScreenState();
}

class _PurchaseOrderDetailsScreenState extends State<PurchaseOrderDetailsScreen> {
  List<Item> _items = [];
  List<PurchaseOrderDetail> _details = [];
  Item? _selectedItem;
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Future<void> _loadItems() async {
    final db = await DBHelper.database;
    final maps = await db.query('items');
    setState(() {
      _items = maps.map((e) => Item.fromMap(e)).toList();
    });
  }

  Future<void> _loadDetails() async {
    final db = await DBHelper.database;
    final maps = await db.query(
      'purchase_order_details',
      where: 'orderId = ?',
      whereArgs: [widget.orderId],
    );
    setState(() {
      _details = maps.map((e) => PurchaseOrderDetail.fromMap(e)).toList();
    });
  }

  Future<void> _addDetail() async {
    if (_selectedItem != null &&
        _qtyController.text.isNotEmpty &&
        _priceController.text.isNotEmpty) {
      final db = await DBHelper.database;
      await db.insert('purchase_order_details', {
        'orderId': widget.orderId,
        'itemId': _selectedItem!.id,
        'quantity': int.parse(_qtyController.text),
        'price': double.parse(_priceController.text),
      });
      _qtyController.clear();
      _priceController.clear();
      _loadDetails();
    }
  }

  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Order ${widget.orderId}'];

    sheet.appendRow(['الصنف', 'الكمية', 'السعر', 'الإجمالي']);

    for (var detail in _details) {
      final item = _items.firstWhere((e) => e.id == detail.itemId);
      sheet.appendRow([
        item.name,
        detail.quantity,
        detail.price,
        detail.quantity * detail.price
      ]);
    }

    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/order_${widget.orderId}.xlsx';
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ الملف: $path')),
    );
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('أمر التوريد رقم ${widget.orderId}',
                  style: pw.TextStyle(font: ttf, fontSize: 20)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['الصنف', 'الكمية', 'السعر', 'الإجمالي'],
                data: _details.map((detail) {
                  final item = _items.firstWhere((e) => e.id == detail.itemId);
                  return [
                    item.name,
                    '${detail.quantity}',
                    '${detail.price}',
                    '${detail.quantity * detail.price}'
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(font: ttf),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/order_${widget.orderId}.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ الملف: ${file.path}')),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل أمر التوريد #${widget.orderId}'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _exportToPDF,
          ),
          IconButton(
            icon: Icon(Icons.table_view),
            onPressed: _exportToExcel,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButton<Item>(
                  hint: const Text('اختر صنف'),
                  value: _selectedItem,
                  items: _items.map((item) {
                    return DropdownMenuItem<Item>(
                      value: item,
                      child: Text(item.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedItem = val),
                ),
                TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الكمية'),
                ),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'السعر'),
                ),
                ElevatedButton(
                  onPressed: _addDetail,
                  child: const Text('إضافة'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _details.length,
              itemBuilder: (context, index) {
                final detail = _details[index];
                final item = _items.firstWhere((e) => e.id == detail.itemId);
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                      'الكمية: ${detail.quantity}, السعر: ${detail.price}, الإجمالي: ${detail.quantity * detail.price}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
