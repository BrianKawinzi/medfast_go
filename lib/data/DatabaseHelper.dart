import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/product.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  // Define your database table and column names
  final String tableName = 'products';
  final String columnId = 'id';
  final String columnProductName = 'productName';
  final String columnMedicineDescription = 'medicineDescription'; // Added this line
  final String columnBuyingPrice = 'buyingPrice';
  final String columnSellingPrice = 'sellingPrice';
  final String columnQuantity = 'quantity';
  final String columnUnit = 'unit';
  final String columnManufactureDate = 'manufactureDate';
  final String columnExpiryDate = 'expiryDate';
  final String columnImage = 'image';

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
      version: 1,
      onCreate: _createDb,
    );
    return database;
  }

  // Create the database table
  void _createDb(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE $tableName (
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
  }

  // Insert a product into the database
  Future<int> insertProduct(Product product) async {
    final Database? db = await database;
    final int result = await db!.insert(tableName, product.toMap());
    return result;
  }

  // Query all products from the database
  Future<List<Product>> getProducts() async {
    final Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(tableName);
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Update a product in the database
  Future<int> updateProduct(Product product) async {
    final Database? db = await database;
    final int result = await db!.update(
      tableName,
      product.toMap(),
      where: '$columnId = ?',
      whereArgs: [product.id],
    );
    return result;
  }

  // Delete a product from the database
  Future<int> deleteProduct(int id) async {
    final Database? db = await database;
    final int result = await db!.delete(
      tableName,
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
