import 'package:flutter/material.dart';
import 'screens/vendors_screen.dart';
import 'screens/items_screen.dart';
import 'screens/purchase_orders_screen.dart';

void main() {
  runApp(const PurchaseOrdersApp());
}

class PurchaseOrdersApp extends StatelessWidget {
  const PurchaseOrdersApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Purchase Orders App',
      theme: ThemeData(
        fontFamily: 'Cairo',
        primarySwatch: Colors.teal,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Widget buildButton(BuildContext context, String label, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          textStyle: const TextStyle(fontSize: 20),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام أوامر التوريد'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildButton(context, 'الموردين', const VendorsScreen()),
            buildButton(context, 'الأصناف', const ItemsScreen()),
            buildButton(context, 'أوامر التوريد', const PurchaseOrdersScreen()),
          ],
        ),
      ),
    );
  }
}
