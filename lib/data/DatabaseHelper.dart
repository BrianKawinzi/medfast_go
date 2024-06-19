import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:medfast_go/models/OrderDetails.dart';
import 'package:medfast_go/models/customers.dart';
import 'package:medfast_go/models/expenses.dart';
import 'package:medfast_go/models/note.dart';
import 'package:medfast_go/models/reminder.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  // Define your database table and column names

  // Table name for products
  final String columnId = 'id';
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
  final String columnsoldQuantity = 'soldQuantity';
  final String columnProductprofit = 'profit';
  final String columnProductBarCode = 'barcode';
  final String columnuserId = 'user_id';
  final String columnLastModified = 'last_modified';
  final String columnPhymacyId = 'pharmacy_id';

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
  final String columnOrderId = 'orderId';
  final String columnTotalPrice = 'totalPrice';
  final String columnProducts =
      'products'; // This will store a JSON string of products
  final String columnCompletedAt = 'completedAt';
  final String columnprofit = 'profit';

  // Table name for Reminders
  final String remindersTableName = 'reminders';
  final String columnReminderTittle = 'tittle';
  final String columnReminderDescription = 'description';
  final String columnReminderTime = 'time';
  final String columnReminderdate = 'date';

  // Table name for notes
  final String notesTableName = 'notes';
  final String columnNoteTittle = 'tittle';
  final String columnNoteDescription = 'description';
  final String columnNoteTime = 'time';
  final String columnNotedate = 'date';

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

  Future<Map<int, int>> calculateTotalSoldQuantities() async {
    Database? db = await database;
    List<Map<String, dynamic>> orders =
        await db!.query(completedOrderTableName);

    Map<int, int> productSales = {};

    for (var order in orders) {
      List<dynamic> products = jsonDecode(order['products']);

      for (var product in products) {
        int id = product['id'];

        if (productSales.containsKey(id)) {
          productSales[id] = productSales[id]! + 1; // Increment count
        } else {
          productSales[id] = 1; // Initialize count
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
        version: 5,
        onCreate: _createDb,
        onUpgrade: _upgradeDb,
      );
      return database;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow; // Rethrow the exception to propagate it further
    }
  }

  // Create the database tables for products and expenses
  void _createDb(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE $productTableName (
        $columnId INTEGER PRIMARY KEY,
        $columnProductName TEXT,
        $columnMedicineDescription TEXT,
        $columnBuyingPrice REAL,
        $columnSellingPrice REAL,
        $columnQuantity INTEGER,
        $columnUnit TEXT,
        $columnManufactureDate TEXT,
        $columnExpiryDate TEXT,
        $columnImage TEXT,
        $columnProductprofit REAL,
        $columnsoldQuantity INTEGER,
        $columnProductBarCode TEXT,
        $columnuserId TEXT,
        $columnLastModified TEXT,
        $columnPhymacyId TEXT
      )
    ''');

    // Create the completed orders table
    await db.execute('''
      CREATE TABLE $completedOrderTableName (
        $columnOrderId TEXT,
        $columnTotalPrice REAL,
        $columnProducts TEXT,
        $columnCompletedAt TEXT,
        $columnprofit REAL
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

    // Create the database table for reminders
    await db.execute('''
      CREATE TABLE $remindersTableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnReminderTittle TEXT,
        $columnReminderDescription TEXT,
        $columnReminderdate TEXT,
        $columnReminderTime TEXT
      )
    ''');

    // Create the database table for notes
    await db.execute('''
      CREATE TABLE $notesTableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNoteTittle TEXT,
        $columnNoteDescription TEXT,
        $columnNotedate TEXT,
        $columnNoteTime TEXT
      )
    ''');
  }

  void _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Upgrade logic for version 2
      await db.execute('''
      CREATE TABLE $completedOrderTableName (
        $columnOrderId TEXT,
        $columnTotalPrice REAL,
        $columnProducts TEXT,
        $columnCompletedAt TEXT,
        $columnprofit REAL
      )
    ''');
    }
    if (oldVersion < 3) {
      // Upgrade logic for version 3
      await db.execute('''
      ALTER TABLE $productTableName ADD COLUMN $columnsoldQuantity INTEGER DEFAULT 0
    ''');
      await db.execute('''
      ALTER TABLE $productTableName ADD COLUMN $columnProductprofit REAL DEFAULT 0.0
    ''');
    }
    if (oldVersion < 4) {
      // Upgrade logic for version 4
      await _createTableIfNotExists(db, remindersTableName, '''
      CREATE TABLE $remindersTableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnReminderTittle TEXT,
        $columnReminderDescription TEXT,
        $columnReminderdate TEXT,
        $columnReminderTime TEXT
      )
    ''');
      await _createTableIfNotExists(db, notesTableName, '''
      CREATE TABLE $notesTableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNoteTittle TEXT,
        $columnNoteDescription TEXT,
        $columnNotedate TEXT,
        $columnNoteTime TEXT
      )
    ''');
    }
    if (oldVersion < 5) {
      // Upgrade logic for version 5
      await db.execute('''
      ALTER TABLE $productTableName ADD COLUMN $columnProductBarCode TEXT
    ''');
    }
  }

  Future<void> _createTableIfNotExists(
      Database db, String tableName, String createTableQuery) async {
    var tableExists = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName';");

    if (tableExists.isEmpty) {
      await db.execute(createTableQuery);
    }
  }

  // Insert a product into the products table
  Future<int> insertProduct(Product product) async {
    final Database? db = await database;
    final int result = await db!.insert(
      productTableName, product.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // This handles duplicate entries
    );
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

// get a rpduct with a specific barcode
  Future getProductByBarcode(String barcode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      productTableName,
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Insert an expense into the expenses table
  Future<int> insertExpense(Expense expense) async {
    final Database? db = await database;
    final int result = await db!.insert(expenseTableName, expense.toMap());
    return result;
  }

  // Insert a reminder into the reminders table
  Future<int> insertReminder(Reminder reminder) async {
    final Database? db = await database;
    final int result = await db!.insert(remindersTableName, reminder.toMap());
    return result;
  }

  // Get all reminders from the reminders table
  Future<List<Reminder>> getReminders() async {
    final Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(remindersTableName);
    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }

  // Delete a reminder
  Future<int> deleteReminder(int id) async {
    final Database? db = await database;
    final int result = await db!.delete(
      remindersTableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return result;
  }

  // Update a reminder in the reminders table
  Future<int> updateReminder(Reminder reminder) async {
    final Database? db = await database;
    final int result = await db!.update(
      remindersTableName,
      reminder.toMap(),
      where: '$columnId = ?',
      whereArgs: [reminder.id],
    );
    return result;
  }

  // Insert a motes into the notes table
  Future<int> insertNote(Note note) async {
    final Database? db = await database;
    final int result = await db!.insert(notesTableName, note.toMap());
    return result;
  }

  // Get all notes from the notes table
  Future<List<Note>> getNotes() async {
    final Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(notesTableName);
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // Delete a note
  Future<int> deleteNote(int id) async {
    final Database? db = await database;
    final int result = await db!.delete(
      notesTableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return result;
  }

  // Update a note in the notes table
  Future<int> updateNote(Note note) async {
    final Database? db = await database;
    final int result = await db!.update(
      notesTableName,
      note.toMap(),
      where: '$columnId = ?',
      whereArgs: [note.id],
    );
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

  // delete products
  Future<void> clearProducts() async {
    final db = await database;
    await db?.delete(productTableName);
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
    final int result = await db!.insert(customerTableName, customer.toMap());
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

  // Fetch daily profit
  // ignore: avoid_types_as_parameter_names
  Future<double> getDailyProfit(DateTime date) async {
    Database? db;
    try {
      db = await database;
      List<Map<String, dynamic>> result = await db!.query(
        completedOrderTableName,
        columns: [
          'IFNULL(SUM(profit), 0) AS dailyProfit'
        ], // Ensures nulls are handled
        where: "DATE($columnCompletedAt) = DATE(?)",
        whereArgs: [date.toIso8601String()],
      );
      return double.tryParse(result.first['dailyProfit'].toString()) ?? 0.0;
    } catch (e) {
      print('Error fetching daily profit: $e');
      return 0.0; // Return 0.0 on error
    }
  }

  //get total price of each and very month
  // Define a function to get the total price of items sold in each month
  Future<Map<String, double>> getTotalPriceByMonth() async {
    final db = await database;
    // Query completed orders grouped by month
    List<Map<String, dynamic>> result = await db!.rawQuery('''
    SELECT strftime('%Y-%m', $columnCompletedAt) AS month,
           SUM($columnTotalPrice) AS totalPrice
    FROM $completedOrderTableName
    GROUP BY month
  ''');

    Map<String, double> totalPriceByMonth = {};
    // Process query result
    for (var row in result) {
      totalPriceByMonth[row['month']] = row['totalPrice'] ?? 0.0;
    }
    return totalPriceByMonth;
  }

  Future<List<OrderDetails>> getTodayCompletedOrders(DateTime date) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db!.query(
      completedOrderTableName,
      where: "DATE($columnCompletedAt) = DATE(?)",
      whereArgs: [date.toIso8601String()],
    );

    return List<OrderDetails>.from(
        result.map((map) => OrderDetails.fromMap(map)));
  }

  // Fetch daily total items sold
  Future<int> getDailyTotalItemsSold(DateTime date) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db!.query(
      completedOrderTableName,
      columns: ['products'], // Retrieve the 'products' column
      where: "DATE($columnCompletedAt) = DATE(?)",
      whereArgs: [date.toIso8601String()],
    );

    int totalProductsSold = 0;
    for (var row in result) {
      List<dynamic> products = jsonDecode(row['products']);
      totalProductsSold += products.length;
    }

    return totalProductsSold;
  }
// Fetch daily expenses

  Future<double> getDailyExpenses(DateTime date) async {
    final db = await database;
    // Ensuring date is in YYYY-MM-DD format for SQL compatibility
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    try {
      List<Map<String, dynamic>> result = await db!.query(expenseTableName,
          columns: ['SUM(cost) AS totalCost'],
          where: "DATE($columnDate) = ?",
          whereArgs: [formattedDate]);

      if (result.isNotEmpty && result.first['totalCost'] != null) {
        return double.tryParse(result.first['totalCost'].toString()) ?? 0.0;
      }
      print(
          "No expenses found for date: $formattedDate"); // Log if no data found
    } catch (e) {
      print("Error fetching expenses for date $formattedDate: $e");
    }
    return 0.0; // Return 0.0 if no expenses or error occurred
  }

  // Future<double> getDailyExpenses(DateTime date) async {
  //   final db = await database;
  //   String formattedDate = date.toIso8601String().substring(0, 10);
  //   try {
  //     List<Map<String, dynamic>> result = await db!.query(
  //       expenseTableName,
  //       columns: ['SUM(cost) AS totalCost'],
  //       where: "DATE($columnDate) = DATE(?)",
  //       whereArgs: [formattedDate]
  //     );

  //     if (result.isNotEmpty && result.first['totalCost'] != null) {
  //       return double.tryParse(result.first['totalCost'].toString()) ?? 0.0;
  //     }
  //   } catch (e) {
  //     print("Error fetching expenses: $e");
  //   }
  //   return 0.0;
  // }

  // Fetch top 3 best-selling products based on total quantity sold
  Future<List<Product>> getTopSellingProducts() async {
    Database? db = await database;
    try {
      // Calculate sold quantities and profits
      Map<int, int> soldQuantities = await calculateTotalSoldQuantities();
      Map<int, double> profit = await calculateProductProfits();

      // Sort products by sold quantity in descending order
      List<MapEntry<int, int>> sortedProducts = soldQuantities.entries.toList();
      sortedProducts.sort((a, b) => b.value.compareTo(a.value));
      List<int> topProductIds =
          sortedProducts.take(3).map((e) => e.key).toList();
      List<Map<String, dynamic>> productMaps = await db!.query(productTableName,
          where: '$columnId IN (${topProductIds.join(', ')})');

      List<Product> products = [];
      for (var productMap in productMaps) {
        int productId = productMap['id'];
        int soldQuantity = soldQuantities[productId] ?? 0;
        double productProfit = profit[productId] ?? 0.0;

        await db.update(productTableName, {'soldQuantity': soldQuantity},
            where: '$columnId = ?', whereArgs: [productId]);

        products.add(Product.fromMap(productMap)
          ..soldQuantity = soldQuantity
          ..profit = productProfit);
      }
      return products;
    } catch (e) {
      print('Error fetching top selling products: $e');
      throw Exception('Failed to fetch top selling products');
    }
  }

  Future<Map<int, double>> calculateProductProfits() async {
    Database? db = await database;
    List<Map<String, dynamic>> newOrders = await db!
        .query(completedOrderTableName, where: '$columnprofit IS NULL');

    Map<int, double> profit = {};

    for (var order in newOrders) {
      List<dynamic> products = jsonDecode(order['products']);

      for (var product in products) {
        int id = product['id'];
        int quantity = product['soldQuantity'];
        double buyingPrice = product['sellingPrice'];
        double sellingPrice = product['buyingPrice'];

        double productProfit = (sellingPrice - buyingPrice) * quantity;

        if (profit.containsKey(id)) {
          profit[id] = profit[id]! + productProfit; // Increment profit
        } else {
          profit[id] = productProfit; // Initialize profit
        }

        // Update the product's profit in the products table
        await db.update(
          productTableName,
          {columnProductprofit: profit[id]},
          where: '$columnId = ?',
          whereArgs: [id],
        );
      }
    }

    return profit;
  }

// Insert a completed order into the completedOrders table and update product quantities
  Future<int> insertCompletedOrderAndUpdateProducts(OrderDetails order) async {
    final db = await database;
    int orderId = await db!.insert(completedOrderTableName, order.toMap());

    // Now update product quantities
    await updateProductQuantitiesAfterOrderCompletion(order);
    return orderId;
  }

// Update product quantities in the product table after an order is completed
  Future<void> updateProductQuantitiesAfterOrderCompletion(
      OrderDetails order) async {
    Database? db = await database;
    List<dynamic> products = jsonDecode(order.products
        as String); // Assuming 'order.products' is a JSON string of products

    for (var product in products) {
      int id = product['id'];
      int soldQuantity = product['soldQuantity'];

      // Fetch current quantity from the database
      List<Map<String, dynamic>> productData = await db!.query(productTableName,
          columns: [columnQuantity], where: '$columnId = ?', whereArgs: [id]);

      if (productData.isNotEmpty) {
        int currentQuantity = productData.first[columnQuantity] as int;

        // Calculate new quantity
        int newQuantity = currentQuantity - soldQuantity;

        // Update the product with new quantity
        await db.update(productTableName, {columnQuantity: newQuantity},
            where: '$columnId = ?', whereArgs: [id]);
      }
    }
  }

  Future<void> updateProductQuantity(int productId, int newQuantity) async {
    final db = await database;
    await db?.update(
      productTableName,
      {columnQuantity: newQuantity},
      where: '$columnId = ?',
      whereArgs: [productId],
    );
  }

  // Close the database
  Future<void> close() async {
    final Database? db = await database;
    db?.close();
  }

  getBestSellingProductsDetails() {}

  calculateMonthlyAndDailySales() {}
}
