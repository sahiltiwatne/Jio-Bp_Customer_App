import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
  CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE,
    password TEXT,
    phone TEXT,
    dob TEXT
  )
''');

      },
    );
  }

  Future<int> registerUser(String email, String password, String phone, String dob) async {
    final dbClient = await db;
    try {
      return await dbClient.insert('users', {
        'email': email,
        'password': password,
        'phone': phone,
        'dob': dob,
      });
    } catch (e) {
      return -1;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String input, String password) async {
    final dbClient = await db;
    final res = await dbClient.query(
      'users',
      where: '(email = ? OR phone = ?) AND password = ?',
      whereArgs: [input, input, password],
    );
    if (res.isNotEmpty) {
      return res.first;
    }
    return null;
  }




}
