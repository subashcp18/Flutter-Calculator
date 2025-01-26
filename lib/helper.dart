import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history(
            question TEXT,
            answer TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertHistory(String question, String answer) async {
    final db = await database;
    return await db.insert(
      'history',
      {'question': question, 'answer': answer},
    );
  }

  Future<List<Map<String, dynamic>>> fetchHistory() async {
    final db = await database;
    return await db.query('history');
  }

  // Future<int> updateItem(int id, String name, int quantity) async {
  //   final db = await database;
  //   return await db.update(
  //     'items',
  //     {'name': name, 'quantity': quantity},
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  // Future<int> deleteItem(int id) async {
  //   final db = await database;
  //   return await db.delete(
  //     'items',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  Future<int> deleteAllHistory() async {
  final db = await database;
  return await db.delete('history'); // Deletes all rows in the table
}

}
