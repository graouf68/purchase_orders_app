import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'purchase_orders.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vendors (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE purchase_orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vendorId INTEGER NOT NULL,
            date TEXT NOT NULL,
            FOREIGN KEY (vendorId) REFERENCES vendors (id)
          )
        ''');
        await db.execute('''
          CREATE TABLE purchase_order_details (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderId INTEGER NOT NULL,
            itemId INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            FOREIGN KEY (orderId) REFERENCES purchase_orders (id),
            FOREIGN KEY (itemId) REFERENCES items (id)
          )
        ''');
      },
    );
  }

  static Future<void> clearAllTables() async {
    final db = await database;
    await db.delete('purchase_order_details');
    await db.delete('purchase_orders');
    await db.delete('items');
    await db.delete('vendors');
  }
}
