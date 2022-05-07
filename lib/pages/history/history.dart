// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/database/database_helper.dart';
import 'package:ordering_services/models/order.dart';
import 'package:ordering_services/models/products.dart';
import 'package:ordering_services/pages/history/transaction.dart';
import 'package:ordering_services/services/order_service/order_service.dart';
import 'package:ordering_services/utils/next_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // final TransactionService transactionService = TransactionService();

  final TextEditingController _searchController = TextEditingController();

  OrderService orderService = OrderService();

  // List<Order> orders = [];

  final List<String> errors = [];
  String _countryCode = "+221";

  bool _loading = false;
  bool _searching = false;
  List<Order> searchingTransactions = [];

  final spinkit = SpinKitRing(
    color: AppColors.greenDark.withOpacity(0.5),
    lineWidth: 10.0,
    size: 100.0,
  );

  @override
  void initState() {
    super.initState();

    // orderService.getOrders(userId).then(
    //   ((value) {
    //     orders = value;
    //     setState(() {
    //       _loading = false;
    //     });
    //   }),
    // );

    // print(orders.first.ref);
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.greenDark,
        title: Text(
          "Historique",
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
        elevation: 0.0,
      ),
      body: _loading
          ? spinkit
          : FutureBuilder(
              future: orderService.getOrders(userId),
              builder: (_, snapshot) {
                print("snapshot.data[0]");
                print(snapshot.data);

                if (snapshot.data != null) {
                  print("snapshot.data[0]");
                  print(snapshot.data);
                  List<Order> orders = snapshot.data;

                  return ListView(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            // height: _height,
                            width: double.infinity,
                            decoration: BoxDecoration(color: Colors.white),
                            child: Column(
                              children: <Widget>[
                                _search(
                                  context,
                                  orders,
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                _latestTransactions(
                                  context,
                                  _searching ? searchingTransactions : orders,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: spinkit,
                  );
                }
              },
            ),
    );
  }

  /// Item TextFromField Search
  Padding _search(BuildContext context, List<Order> orders) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 5.0, left: 5.0),
      child: Container(
        height: 50.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(25.0),
          ),
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 10.0),
            child: Theme(
              data: ThemeData(hintColor: Colors.transparent),
              child: TextFormField(
                controller: _searchController,
                onChanged: (value) {
                  print(value);
                  setState(() {
                    _searching = true;
                    searchingTransactions = orders
                        .where(
                          (Order order) => order.ref
                              .toLowerCase()
                              .contains(value.toLowerCase()),
                        )
                        .toList();
                  });
                },
                onFieldSubmitted: (value) => {
                  _searchController.clear(),
                  setState(() {
                    _searching = false;
                  }),
                },
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13.0,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 28.0,
                  ),
                  hintText: "Rechercher avec le numéro",
                  hintStyle: TextStyle(
                    fontSize: 12.0,
                    // color: gray.withOpacity(0.5),
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding _latestTransactions(BuildContext context, List<Order> orders) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 20,
        left: 5,
        right: 5,
      ),
      child: orders.isEmpty
          ? Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 8,
                right: 8,
              ),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 25.0, // soften the shadow
                    spreadRadius: 5.0, //extend the shadow
                    offset: Offset(
                      0.0, // Move to right 10  horizontally
                      1.0, // Move to bottom 10 Vertically
                    ),
                  )
                ],
                color: Colors.white,
              ),
              width: double.infinity,
              child: Center(
                child: Text(
                  "Aucune transaction",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    // color: gray.withOpacity(0.4),
                  ),
                ),
              ),
            )
          : Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 8,
                right: 8,
              ),
              // height: 500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 25.0, // soften the shadow
                    spreadRadius: 5.0, //extend the shadow
                    offset: Offset(
                      0.0, // Move to right 10  horizontally
                      1.0, // Move to bottom 10 Vertically
                    ),
                  )
                ],
                color: Colors.white,
              ),
              width: double.infinity,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (BuildContext context, int index) {
                  Order order = orders[index];
                  return buildList(
                    context,
                    order,
                    index == orders.length - 1,
                  );
                },
              ),
            ),
    );
  }

  // History
  Widget buildList(
    BuildContext context,
    Order order,
    bool isTheLast,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        // bottom: 10,
        // left: 10,
        // right: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
          topLeft: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
      ),
      child: Column(
        children: <Widget>[
          _historyItem(context, order),
          !isTheLast
              ? Divider(
                  color: Colors.black38,
                )
              : Divider(
                  color: Colors.white,
                ),
        ],
      ),
    );
  }

  Widget _historyItem(BuildContext context, Order order) {
    return InkWell(
      onTap: () async {
        nextScreenPopup(
          context,
          OrderPage(
            order: order,
          ),
        );
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.only(
          top: 5,
          bottom: 0,
          left: 10,
          right: 10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  order.ref,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _formatDate(
                    DateTime.parse(order.date),
                  ),
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  _formatCurrencyForList(order.totalAmount),
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Succès",
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

String _formatDate(DateTime date) {
  final format = DateFormat('dd/MM/yyyy HH:mm:ss');
  return format.format(date);
}

String _formatCurrencyForList(num amount) {
  var f =
      NumberFormat.currency(locale: "fr-FR", symbol: "FCFA", decimalDigits: 0);
  return f.format(amount);
}

String _formatCurrency(num amount) {
  var f =
      NumberFormat.currency(locale: "fr-FR", symbol: "Fcfa", decimalDigits: 0);
  return f.format(amount);
}
