import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';

class DBHelper {
  static const String tableName = 'transactions';
  static Database? _db;

  // Inisialisasi Database
  static Future<Database> initDB() async {
    if (_db != null) return _db!;
    final path = await getDatabasesPath();
    final dbPath = join(path, 'transactions.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            userId TEXT,
            category TEXT,
            amount REAL,
            description TEXT,
            date TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  // Tambah transaksi
  static Future<void> addTransaction(TransactionModel transaction) async {
    final db = await initDB();
    await db.insert(tableName, transaction.toMap());
  }

  // Ambil semua transaksi
  static Future<List<TransactionModel>> getTransactions() async {
    final db = await initDB();
    final List<Map<String, dynamic>> data = await db.query(tableName);
    return data.map((e) => TransactionModel.fromMap(e)).toList();
  }

  // Hapus transaksi
  static Future<void> deleteTransaction(String id) async {
    final db = await initDB();
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Update transaksi
  static Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await initDB();
    await db.update(
      tableName,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }
}
