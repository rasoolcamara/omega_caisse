import 'dart:convert';

import 'package:ordering_services/models/products.dart';

class Order {
  Order({
    this.id,
    this.userId,
    this.ref,
    this.description,
    this.products,
    this.date,
    this.totalAmount,
  });

  int id;
  int userId;
  String ref;
  String date;
  String description;
  // List<Product> products;
  List<dynamic> products;
  int totalAmount;

  factory Order.fromJson(Map<String, dynamic> json) {
    // print(json['detail']);
    try {
      return Order(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        ref: json['name'] as String,
        description:
            json['description'] != null ? json['description'] as String : '',
        totalAmount: json['amount'] as num,
        date: json['datetime'] != null
            ? json['datetime'] as String
            : "2020-03-09 23:59:58",
        products:
            json['detail'] != null ? json['detail'] : jsonDecode(json['data']),
      );
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
