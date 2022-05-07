import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/models/order.dart';
import 'package:ordering_services/models/products.dart';
import 'package:ordering_services/services/order_service/order_service.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// singleton class to manage the database
class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "OmegaCaisse.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) {
      // databaseFactory.deleteDatabase(_databaseName);

      return _database;
    }

    // databaseFactory.deleteDatabase(_databaseName);

    _database = await _initDatabase();

    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    ///
    /// Orders Table Creating
    ///
    await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            user_id INTEGER NOT NULL,
            data TEXT NOT NULL,
            amount INTEGER NOT NULL,
            datetime TEXT NOT NULL
          )
          ''');

    ///
    /// Products Table Creating
    ///
    await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            path TEXT NOT NULL,
            price INTEGER NOT NULL,
            quantity INTEGER NOT NULL
          )
          ''');
  }

  // Database helper methods:

  Future<Order> insertOrder(List<Product> products) async {
    var totalAmount = 0;
    List<Map<String, dynamic>> productMap = [];
    products.forEach((e) {
      totalAmount += e.price * e.quantity;
      productMap
          .add({"name": e.name, "price": e.price, "quantity": e.quantity});
    });
    final format = DateFormat('ddMMyyHHmm');

    var ref = "OFFLINEORDER_" + format.format(DateTime.now());
    // print(productMap);
    Database db = await database;
    int id = await db.insert(
        'orders',
        ({
          "amount": totalAmount,
          "name": ref,
          "user_id": userId,
          "data": jsonEncode(productMap),
          "datetime": DateTime.now().toString(),
        }));
    final order = await queryOrder(id);
    return order;
  }

  Future<Order> queryOrder(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(
      'orders',
      columns: ['id', 'name', 'user_id', 'datetime', 'amount', 'data'],
      where: 'id = ?',
      whereArgs: [id],
    );
    // print("RESULT");
    // print(maps);

    if (maps.length > 0) {
      return Order.fromJson(maps.first);
    }
    return null;
  }

  Future<List<Order>> queryAllOrders() async {
    Database db = await database;
    List<Map> maps =
        await db.rawQuery('SELECT * FROM orders ORDER BY datetime DESC');
    // print("RESULT orders");
    // print(maps);
    if (maps.length > 0) {
      List<Order> orders = maps
          .map(
            (dynamic item) => Order.fromJson(item),
          )
          .toList();
      return orders;
    }
    return [];
  }

  ///
  /// Products Helpers Methods
  ///

  Future<Product> insertProduct(Product product) async {
    Database db = await database;
    int id = await db.insert(
      'products',
      ({
        "name": product.name,
        "price": product.price,
        "path": product.image,
        "quantity": product.quantity,
      }),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // print("RESULT products");
    // print(id);

    final prod = await queryProduct(id);
    return prod;
  }

  Future<Product> queryProduct(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(
      'products',
      columns: [
        'id',
        'name',
        'path',
        'price',
        'quantity',
      ],
      where: 'id = ?',
      whereArgs: [id],
    );
    // print("RESULT products");
    // print(maps);

    if (maps.length > 0) {
      return Product.fromJson(maps.first);
    }
    return null;
  }

  Future<List<Product>> queryAllProducts() async {
    Database db = await database;
    List<Map> maps = await db.rawQuery('SELECT * FROM products');

    if (maps.length > 0) {
      List<Product> products = maps
          .map(
            (dynamic item) => Product.fromJson(item),
          )
          .toList();
      return products;
    }
    return null;
  }

  Future<int> deleteAllProducts() async {
    Database db = await database;

    List<Map> maps = await db.rawQuery('SELECT * FROM products');

    maps.forEach((e) async {
      int id = await db.rawDelete('DELETE FROM products WHERE id = ${e['id']}');
      // print("COUNT *");
      // print(id);
      maps.remove(e);
    });
    // print("COUNT FIN deleteAllProducts *");
    // print(maps.length);
    return maps.length;
  }

  Future<int> deleteAllOrders() async {
    Database db = await database;

    List<Map> maps = await db.rawQuery('SELECT * FROM orders');
    print("THE ORDERRRR");

    maps.forEach((e) async {
      var data = jsonDecode(e["data"]);
      print("THE ORDERRRR");

      List<Product> products = [];

      data.forEach((el) {
        products.add(Product(
            name: el['name'], price: el['price'], quantity: el['quantity']));
      });

      print("THE PRODUCTSS");
      print(products.length);

      final result = await OrderService().newOrder(
        e["amount"],
        products,
      );
      print("result");
      print(result);

      int id = await db.rawDelete('DELETE FROM orders WHERE id = ${e['id']}');
      // print("COUNT *");
      // print(id);
      maps.remove(e);
    });

    // print("COUNT FIN *");
    // print(maps.length);
    return maps.length;
  }
  // TODO: queryAllWords()
  // TODO: delete(int id)
  // TODO: update(Word word)
}
