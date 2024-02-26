// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// import '../models/product.dart';

// class DatabaseHelper {
//   static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
//   static Database? _database; // Singleton Database

//   // Define your database table and column names
//   final String tableName = 'products';
//   final String columnId = 'id';
//   final String columnProductName = 'productName';
//   final String columnMedicineDescription = 'medicineDescription'; // Added this line
//   final String columnBuyingPrice = 'buyingPrice';
//   final String columnSellingPrice = 'sellingPrice';
//   final String columnQuantity = 'quantity';
//   final String columnUnit = 'unit';
//   final String columnManufactureDate = 'manufactureDate';
//   final String columnExpiryDate = 'expiryDate';
//   final String columnImage = 'image';

//   // Singleton constructor
//   factory DatabaseHelper() {
//     if (_databaseHelper == null) {
//       _databaseHelper = DatabaseHelper._createInstance();
//     }
//     return _databaseHelper!;
//   }

//   DatabaseHelper._createInstance();

//   // Get a reference to the database and create it if necessary
//   Future<Database?> get database async {
//     if (_database == null) {
//       _database = await initializeDatabase();
//     }
//     return _database;
//   }

//   // Initialize the database
//   Future<Database> initializeDatabase() async {
//     final String path = join(await getDatabasesPath(), 'medfast_go.db');
//     final Database database = await openDatabase(
//       path,
//       version: 1,
//       onCreate: _createDb,
//     );
//     return database;
//   }

//   // Create the database table
//   void _createDb(Database db, int newVersion) async {
//     await db.execute('''
//       CREATE TABLE $tableName (
//         $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
//         $columnProductName TEXT,
//         $columnMedicineDescription TEXT,
//         $columnBuyingPrice REAL,
//         $columnSellingPrice REAL,
//         $columnQuantity INTEGER,
//         $columnUnit TEXT,
//         $columnManufactureDate TEXT,
//         $columnExpiryDate TEXT,
//         $columnImage TEXT
//       )
//     ''');
//   }

//   // Insert a product into the database
//   Future<int> insertProduct(Product product) async {
//     final Database? db = await database;
//     final int result = await db!.insert(tableName, product.toMap());
//     return result;
//   }

//   // Query all products from the database
//   Future<List<Product>> getProducts() async {
//     final Database? db = await database;
//     final List<Map<String, dynamic>> maps = await db!.query(tableName);
//     return List.generate(maps.length, (i) {
//       return Product.fromMap(maps[i]);
//     });
//   }

//   // Update a product in the database
//   Future<int> updateProduct(Product product) async {
//     final Database? db = await database;
//     final int result = await db!.update(
//       tableName,
//       product.toMap(),
//       where: '$columnId = ?',
//       whereArgs: [product.id],
//     );
//     return result;
//   }

//   // Delete a product from the database
//   Future<int> deleteProduct(int id) async {
//     final Database? db = await database;
//     final int result = await db!.delete(
//       tableName,
//       where: '$columnId = ?',
//       whereArgs: [id],
//     );
//     return result;
//   }

//   // Close the database
//   Future<void> close() async {
//     final Database? db = await database;
//     db?.close();
//   }
// }

import 'package:medfast_go/models/expenses.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/product.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  // Define your database table and column names
  final String productTableName = 'products'; // Table name for products
  final String expenseTableName = 'expenses'; // Table name for expenses
  final String columnId = 'id';
  final String columnProductName = 'productName';
  final String columnMedicineDescription = 'medicineDescription';
  final String columnBuyingPrice = 'buyingPrice';
  final String columnSellingPrice = 'sellingPrice';
  final String columnQuantity = 'quantity';
  final String columnUnit = 'unit';
  final String columnManufactureDate = 'manufactureDate';
  final String columnExpiryDate = 'expiryDate';
  final String columnImage = 'image';
  final String columnDate = 'date';
  final String columnExpenseName = 'expenseName';
  final String columnExpenseDetails = 'expenseDetails';
  final String columnCost = 'cost';

  // Singleton constructor
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper!;
  }

  DatabaseHelper._createInstance();

  // Get a reference to the database and create it if necessary
  Future<Database?> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  // Initialize the database
  Future<Database> initializeDatabase() async {
    final String path = join(await getDatabasesPath(), 'medfast_go.db');
    final Database database = await openDatabase(
      path,
      version: 2, // Increase the version to recreate the database
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
    return database;
  }

  // Create the database tables for products and expenses
  void _createDb(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE $productTableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnProductName TEXT,
        $columnMedicineDescription TEXT,
        $columnBuyingPrice REAL,
        $columnSellingPrice REAL,
        $columnQuantity INTEGER,
        $columnUnit TEXT,
        $columnManufactureDate TEXT,
        $columnExpiryDate TEXT,
        $columnImage TEXT
      )
    ''');

    // Create the expenses table
    await db.execute('''
      CREATE TABLE $expenseTableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnDate TEXT,
        $columnExpenseName TEXT,
        $columnExpenseDetails TEXT,
        $columnCost REAL
      )
    ''');
  }

  // Handle database upgrades
  void _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Upgrade logic for version 2
      Batch batch = db.batch();
      batch.execute('''
      CREATE TABLE $expenseTableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnDate TEXT,
        $columnExpenseName TEXT,
        $columnExpenseDetails TEXT,
        $columnCost REAL
      )
    ''');
      batch.commit();
    }
  }

  // Insert a product into the products table
  Future<int> insertProduct(Product product) async {
    final Database? db = await database;
    final int result = await db!.insert(productTableName, product.toMap());
    return result;
  }

  // Query all products from the products table
  Future<List<Product>> getProducts() async {
    final Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(productTableName);
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Insert an expense into the expenses table
  Future<int> insertExpense(Expense expense) async {
    final Database? db = await database;
    final int result = await db!.insert(expenseTableName, expense.toMap());
    return result;
  }

  // Query all expenses from the expenses table
  Future<List<Expense>> getExpenses() async {
    final Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(expenseTableName);
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // Update a product in the products table
  Future<int> updateProduct(Product product) async {
    final Database? db = await database;
    final int result = await db!.update(
      productTableName,
      product.toMap(),
      where: '$columnId = ?',
      whereArgs: [product.id],
    );
    return result;
  }

  // Delete a product from the products table
  Future<int> deleteProduct(int id) async {
    final Database? db = await database;
    final int result = await db!.delete(
      productTableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return result;
  }

  // Update an expense in the expenses table
  Future<int> updateExpense(Expense expense) async {
    final Database? db = await database;
    final int result = await db!.update(
      expenseTableName,
      expense.toMap(),
      where: '$columnId = ?',
      whereArgs: [expense.id],
    );
    return result;
  }

  // Delete an expense from the expenses table
  Future<int> deleteExpense(int id) async {
    final Database? db = await database;
    final int result = await db!.delete(
      expenseTableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return result;
  }

  // Close the database
  Future<void> close() async {
    final Database? db = await database;
    db?.close();
  }
}
