import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import '../model/todos.dart';

class DatabaseViewModel {
  static DatabaseViewModel _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String todoTable = 'todo_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colSection = 'section';
  String colColor = 'color';
  String colDate = 'date';

  DatabaseViewModel._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseViewModel() {
    _databaseHelper ??= DatabaseViewModel
          ._createInstance();
    return _databaseHelper;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}todos.db';

    // Open/create the database at a given path
    var todosDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todosDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $todoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colSection INTEGER, $colColor INTEGER,$colDate TEXT)');
  }

  // Fetch Operation: Get all todos objects from database
  Future<List<Map<String, dynamic>>> getToDoMapList() async {
    Database db = await database;
    var result = await db.query(todoTable, orderBy: '$colSection ASC');
    return result;
  }

  // Insert Operation: Insert a object to database
  Future<int> insertToDo(ToDO todo) async {
    Database db = await database;
    var result = await db.insert(todoTable, todo.toMap());
    return result;
  }

  // Update Operation: Update a ToDo object and save it to database
  Future<int> updateToDo(ToDO todo) async {
    var db = await database;
    var result = await db.update(todoTable, todo.toMap(),
        where: '$colId = ?', whereArgs: [todo.id]);
    return result;
  }

  // Delete Operation: Delete a ToDo object from database
  Future<int> deleteToDo(int id) async {
    var db = await database;
    int result =
        await db.rawDelete('DELETE FROM $todoTable WHERE $colId = $id');
    return result;
  }

  // Get number of ToDo objects in database
  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $todoTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'ToDo List' [ List<ToDo> ]
  Future<List<ToDO>> getToDoList() async {
    var todoMapList = await getToDoMapList(); // Get 'Map List' from database
    int count =
        todoMapList.length; // Count the number of map entries in db table

    List<ToDO> todoList = [];
    // For loop to create a 'ToDo List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      todoList.add(ToDO.fromMapObject(todoMapList[i]));
    }

    return todoList;
  }

}
