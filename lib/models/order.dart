import 'package:ordering_services/models/products.dart';

class Order {
  Order({
    this.id,
    this.ref,
    this.products,
    this.date,
    this.totalAmount,
  });

  int id;
  String ref;
  String date;
  List<Product> products;
  int totalAmount;
}
