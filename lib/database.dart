import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'notications_model.dart';

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
    final directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'person.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Create the Person table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE person (
        userId TEXT PRIMARY KEY,
        name TEXT,
        url TEXT,
        collectionName TEXT,
        location TEXT,
        motto TEXT,
        genre TEXT,
        timestamp INTEGER
      )
    ''');
  }

  // Insert a person into the database
  Future<int> insertPerson(Person person) async {
    final db = await database;
    return await db.insert('person', person.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get a person by userId
  Future<Person?> getPerson(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
    await db.query('person', where: 'userId = ?', whereArgs: [userId]);

    if (maps.isNotEmpty) {
      return Person.fromJson(maps.first);
    }
    return null;
  }

  // Get all people from the database
  Future<List<Person>> getAllPersons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('person');
    return List.generate(maps.length, (i) {
      return Person.fromJson(maps[i]);
    });
  }

  // Delete a person by userId
  Future<void> deletePerson(String userId) async {
    final db = await database;
    await db.delete('person', where: 'userId = ?', whereArgs: [userId]);
  }

  // Update a person
  Future<void> updatePerson(Person person) async {
    final db = await database;
    await db.update('person', person.toMap(),
        where: 'userId = ?', whereArgs: [person.userId]);
  }
}
