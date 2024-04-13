
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:medfast_go/business/sales.dart';
import 'package:medfast_go/models/OrderDetails.dart';
import 'package:medfast_go/models/customers.dart';
import 'package:medfast_go/models/expenses.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  // Define your database table and column names

  final String columnId = 'id';

  // Table name for products
  final String productTableName = 'products';
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

  // Table name for expenses
  final String expenseTableName = 'expenses';

  final String columnExpenseName = 'expenseName';
  final String columnExpenseDetails = 'expenseDetails';
  final String columnCost = 'cost';

  // Table name for Customers
  final String customerTableName = 'customers'; // Table name for customers
  final String columnName = 'name';
  final String columnContactNo = 'contactNo';
  final String columnEmailAddress = 'emailAddress';

  //Table for completed orders
  final String completedOrderTableName = 'completedOrders';
  final String columnTotalPrice = 'totalPrice';
  final String columnProducts =
      'products'; // This will store a JSON string of products
  final String columnCompletedAt = 'completedAt';





// Table name and columns for Sales History
// final String salesHistoryTableName = 'salesHistory';
// final String columnSoldProductName = 'productName';
// final String columnQuantitySold = 'quantitySold';
// final String columnCurrentStock = 'currentStock';
// final String columnUnitPrice = 'unitPrice';
// final String columnSoldTotalPrice = 'totalPrice1';
// final String columnProfit = 'profit';



  // Singleton constructor
  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  DatabaseHelper._createInstance();

  // Get a reference to the database and create it if necessary
  Future<Database?> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }
  // In DatabaseHelper

// Method to fetch and aggregate product sales from completed orders
Future<Map<int, int>> calculateTotalSoldQuantities() async {
  Database? db = await database;
  List<Map<String, dynamic>> orders = await db!.query(completedOrderTableName);

  Map<int, int> productSales = {};

  for (var order in orders) {
    // Assuming 'products' column contains a JSON string of product details
    List<dynamic> products = jsonDecode(order['products']);

    for (var product in products) {
      int id = product['id'];
      int quantity = product['quantity'];

      if (productSales.containsKey(id)) {
        productSales[id] = productSales[id]! + quantity;
      } else {
        productSales[id] = quantity;
      }
    }
  }

  return productSales;
}


  // Initialize the database
  Future<Database> initializeDatabase() async {
    try {
      final String path = join(await getDatabasesPath(), 'medfast_go.db');
      final Database database = await openDatabase(
        path,
        version: 4,
        onCreate: _createDb,
        onUpgrade: _upgradeDb,
      );
      return database;
    } catch (e) {
      print('Error initializing database: $e');
      throw e; // Rethrow the exception to propagate it further
    }
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


    // Create the completed orders table
    await db.execute('''
      CREATE TABLE $completedOrderTableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId TEXT,
        $columnTotalPrice REAL,
        $columnProducts TEXT,
        $columnCompletedAt TEXT
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

    // Create the database table for customers
    await db.execute('''
      CREATE TABLE $customerTableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT,
        $columnContactNo TEXT,
        $columnEmailAddress TEXT,
        $columnDate TEXT
      )
    ''');
    await db.execute('''
    CREATE TABLE AppState (
      id INTEGER PRIMARY KEY,
      lastRoute TEXT
    )
  ''');
  }

  // Handle database upgrades
  void _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Upgrade logic for version 2
      await db.execute('''
      CREATE TABLE completedOrders (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId TEXT,
        $columnTotalPrice REAL,
        $columnProducts TEXT,
        $columnCompletedAt TEXT
      )
    ''');
     

   
      // await db.execute('''
      //   CREATE TABLE $salesHistoryTableName (
      //     $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      //     $columnSoldProductName TEXT,
      //     $columnQuantitySold INTEGER,
      //     $columnCurrentStock INTEGER,
      //     $columnUnitPrice REAL,
      //     $columnSoldTotalPrice REAL,
      //     $columnProfit REAL
      //   )
      // ''');

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

  // Delete a notification from the database
  Future<int> deleteNotification(String notification) async {
    final Database? db = await database;
    final int result = await db!.delete(
      productTableName,
      where: '$columnProductName = ?',
      whereArgs: [notification],
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

  // Insert a customer into the customers table
  Future<int> insertCustomer(Customer customer) async {
    final Database? db = await database;
    final int result = await db!.insert(
      customerTableName,
      customer.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Specify conflict algorithm
    );
    return result;
  }

  // Query all customers from the customers table
  Future<List<Customer>> getCustomers() async {
    final Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(customerTableName);
    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  // Update a customer in the customers table
  Future<int> updateCustomer(Customer customer) async {
    final Database? db = await database;
    final int result = await db!.update(
      customerTableName,
      customer.toMap(),
      where: '$columnId = ?',
      whereArgs: [customer.id],
    );
    return result;
  }

  // Delete a customer from the customers table
  Future<int> deleteCustomer(int id) async {
    final Database? db = await database;
    final int result = await db!.delete(
      customerTableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return result;
  }

  // Insert a completed order into the completedOrders table
  Future<int> insertCompletedOrder(OrderDetails order) async {
    final db = await database;
    return await db!.insert(completedOrderTableName, order.toMap());
  }

  // Query all completed orders from the completedOrders table
  Future<List<OrderDetails>> getCompletedOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db!.query(completedOrderTableName);
    return List.generate(maps.length, (i) => OrderDetails.fromMap(maps[i]));
  }

  

  

// Insert a record into the sales history table
// Future<int> insertSalesHistory(SalesHistoryClass salesHistory) async {
//   final Database? db = await database;
//   final Map<String, dynamic> data = {
//     columnSoldProductName: salesHistory.productName,
//     columnQuantitySold: salesHistory.quantitySold,
//     columnCurrentStock: salesHistory.currentStock,
//     columnUnitPrice: salesHistory.unitPrice,
//     columnSoldTotalPrice: salesHistory.totalPrice,
//       columnProfit: salesHistory.profit,
//   };
//   return await db!.insert(salesHistoryTableName, data);
// }

// // Retrieve all sales history records
// Future<List<SalesHistoryClass>> getSalesHistory() async {
//   final Database? db = await database;
//   final List<Map<String, dynamic>> maps = await db!.query(salesHistoryTableName);
//   return List.generate(maps.length, (i) {
//     return SalesHistoryClass(
//       productName: maps[i][columnSoldProductName],
//       quantitySold: maps[i][columnQuantitySold],
//       currentStock: maps[i][columnCurrentStock],
//       unitPrice: maps[i][columnUnitPrice],
//       totalPrice: maps[i][columnSoldTotalPrice],
//         profit: maps[i][columnProfit],
//     );
//   });
// }

  

// Close the database
  Future<void> close() async {
    final Database? db = await database;
    db?.close();
  }

  getBestSellingProductsDetails() {}

}
