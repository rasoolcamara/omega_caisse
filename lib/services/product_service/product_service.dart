import 'dart:convert';
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/database/database_helper.dart';
import 'package:ordering_services/models/products.dart';
import 'package:http/http.dart' as http;

class ProductService {
  Future<List<Product>> getProducts(int id) async {
    http.Response res = await http.get(
      Uri.parse(baseURL + 'user/$id/products'),
      headers: <String, String>{
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
        "Authorization": "Bearer $activeToken",
      },
    );

    // print(jsonDecode(res.body));
    var body = jsonDecode(res.body);
    if (body['success'] == true) {
      List<dynamic> productsBody = body['data'];
      deleteProducts();
      deleteOrders();
      List<Product> products = productsBody.map(
        (dynamic item) {
          Product product = Product.fromJson(item);
          createProduct(product);
          return product;
        },
      ).toList();

      return products;
    } else {
      return null;
    }
  }

  Future<Product> createProduct(Product product) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    final prod = await helper.insertProduct(product);
    // print('inserted row: ${prod.name}');
    return prod;
  }

  Future<bool> deleteProducts() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    final prod = await helper.deleteAllProducts();
    // print('inserted row: $prod');
    return true;
  }

  Future<bool> deleteOrders() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    final prod = await helper.deleteAllOrders();
    // print('inserted row: $prod');
    return true;
  }
}
