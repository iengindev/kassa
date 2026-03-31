import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'kassa.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE products(
          code TEXT PRIMARY KEY,
          name TEXT,
          price INTEGER
        )
      ''');
      },
    );
  }

  static Future<void> insertProduct(String code, String name, int price) async {
    final db = await database;

    await db.insert('products', {
      'code': code,
      'name': name,
      'price': price,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, dynamic>?> getProduct(String code) async {
    final db = await database;

    final result = await db.query(
      'products',
      where: 'code = ?',
      whereArgs: [code],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }
}
