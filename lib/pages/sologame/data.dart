import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'snake_game.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE player (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        score INTEGER NOT NULL,
        temps INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertPlayer(String nom, int score, int temps) async {
    final db = await database;
    return await db.insert('player', {
      'nom': nom,
      'score': score,
      'temps': temps,
    });
  }

  Future<List<Map<String, dynamic>>> getPlayers() async {
    final db = await database;
    return await db.query('player', orderBy: 'score DESC');
  }
}
