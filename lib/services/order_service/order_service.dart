import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/database/database_helper.dart';
import 'package:ordering_services/models/order.dart';
import 'package:ordering_services/models/products.dart';
import 'package:http/http.dart' as http;

class OrderService {
  Future<List<Order>> getOrders(
    int id, {
    String startDay,
    String endDay,
  }) async {
    var day = _formatDate(DateTime.now());
    TimeOfDay now = TimeOfDay.now();

    TimeOfDay releaseTime = TimeOfDay(hour: 4, minute: 59);

    var h = now.hour > 10 ? now.hour : "0${now.hour}";
    var m = now.minute > 10 ? now.minute : "0${now.minute}";

    var endDate = "$day $h:$m:59";
    print(endDate);
    var startDate = '';
    if (now.hour < 4) {
      var day1 = _formatDate(DateTime.now().subtract(Duration(days: 1)));
      var h1 =
          releaseTime.hour > 10 ? releaseTime.hour : "0${releaseTime.hour}";

      startDate = "$day1 $h1:${releaseTime.minute}:59";
    } else {
      var h2 =
          releaseTime.hour > 10 ? releaseTime.hour : "0${releaseTime.hour}";
      startDate = "$day $h2:${releaseTime.minute}:59";
    }

    // print("startDate");
    // print("endDate");

    // print(startDate);
    // print(endDate);
    var ords = [];
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      if (startDay != null && endDay != null) {
        http.Response res = await http.get(
          Uri.parse(baseURL + 'user/$id/orders/$startDay/$endDay'),
          headers: <String, String>{
            "Content-Type": "application/json",
            "X-Requested-With": "XMLHttpRequest",
            "Authorization": "Bearer $activeToken",
          },
        );

        // print(jsonDecode(res.body));
        var body = jsonDecode(res.body);
        if (body['success'] == true) {
          List<dynamic> ordersBody = body['data'];

          List<Order> orders = ordersBody
              .map(
                (dynamic item) => Order.fromJson(item),
              )
              .toList();
          // print(orders.first.products);
          return orders;
        } else {
          return null;
        }
      } else {
        http.Response res = await http.get(
          Uri.parse(baseURL + 'user/$id/orders/$startDate/$endDate'),
          headers: <String, String>{
            "Content-Type": "application/json",
            "X-Requested-With": "XMLHttpRequest",
            "Authorization": "Bearer $activeToken",
          },
        );

        // print(jsonDecode(res.body));
        var body = jsonDecode(res.body);
        if (body['success'] == true) {
          List<dynamic> ordersBody = body['data'];

          List<Order> orders = ordersBody
              .map(
                (dynamic item) => Order.fromJson(item),
              )
              .toList();
          // print(orders.first.products);
          return orders;
        } else {
          return null;
        }
      }
    } else {
      if (startDay != null && endDay != null) {
        List<Order> ordes = await getOfflineOrders(startDay, endDay);
        // print("O est ici");
        // print(ordes.length);
        // print("THERE");
        return ordes;
      } else {
        List<Order> ordes = await getOfflineOrders(startDate, endDate);
        // print("O est ici");
        // print(ordes.length);
        // print("THERE");
        return ordes;
      }
    }
  }

  Future<List<Order>> getOfflineOrders(
      String _startDate, String _endDate) async {
    DatabaseHelper helper = DatabaseHelper.instance;

    List<Order> orders = await helper.queryAllOrders();
    orders = orders.where((Order order) {
      var date = DateTime.parse(order.date);

      var startDay = DateTime.parse(_startDate);

      var endDay = DateTime.parse(_endDate);
      return date.isAfter(startDay) && date.isBefore(endDay);
    }).toList();
    if (orders == null) {
      // print('read row ${orders.length}: empty');
      return [];
    } else {
      // print('read row length: ${orders.length}');
      return orders.length == 0 ? [] : orders;
    }
  }

  Future<Order> newOrder(num totalAmount, List<Product> products) async {
    List<Map<String, dynamic>> productMap = [];
    products.forEach((e) {
      productMap
          .add({"name": e.name, "price": e.price, "quantity": e.quantity});
    });

    // print("The productMap");
    // print(productMap);
    http.Response res = await http.post(
      Uri.parse(baseURL + 'orders'),
      body: jsonEncode({
        "amount": totalAmount,
        "detail": jsonEncode(productMap),
        // "date": DateTime.now(),
        "description": null
      }),
      headers: <String, String>{
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
        "Authorization": "Bearer $activeToken",
      },
    );

    // print("Nnew Order Data");
    // print(jsonDecode(res.body));
    var body = jsonDecode(res.body);
    if (body['success'] == true) {
      Order order = Order.fromJson(body['data']);
      // List<Order> orders = await getOrders(activeUser.id);

      return order;
    } else {
      return null;
    }
  }
}

String _formatDate(DateTime date) {
  final format = DateFormat('yyyy-MM-dd');
  return format.format(date);
}
