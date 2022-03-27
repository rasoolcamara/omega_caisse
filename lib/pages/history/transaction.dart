// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/models/order.dart';
import 'package:ordering_services/models/products.dart';
import 'package:ordering_services/widget/button.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderPage extends StatefulWidget {
  OrderPage({
    Key key,
    this.order,
  }) : super(key: key);
  Order order;

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  // final UserService userService = UserService();

  final TextEditingController _searchController = TextEditingController();

  final List<String> errors = [];
  String _countryCode = "+221";

  bool _loading = false;

  final spinkit = SpinKitRing(
    color: AppColors.greenDark.withOpacity(0.5),
    lineWidth: 10.0,
    size: 100.0,
  );

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
          "Reçu",
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
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: _height,
                    width: double.infinity,
                    // padding: const EdgeInsets.only(bottom: 100.0),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
                        // Montant
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            top: 16.0,
                          ),
                          child: Text(
                            widget.order.ref,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        // Date
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 5.0,
                            right: 5.0,
                            top: 16.0,
                          ),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                "Date ",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            subtitle: Text(
                              _formatDate(DateTime.parse(widget.order.date)),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            left: 22.0,
                            right: 22.0,
                            top: 16.0,
                          ),
                          
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Description",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "Montant",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 24.0,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: widget.order.products.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Product product =
                                      widget.order.products[index];
                                  return buildList(
                                    context,
                                    product,
                                    index == widget.order.products.length - 1,
                                  );
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(widget.order.totalAmount),
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 50.0,
                              ),
                              Center(
                                child: SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    color: AppColors.greenDark,
                                    onPressed: () {},
                                    child: Text(
                                      "Imprimer le reçu",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // History
  Widget buildList(
    BuildContext context,
    Product product,
    bool isTheLast,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: 1,
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
          _historyItem(context, product),
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

  Widget _historyItem(BuildContext context, Product product) {
    return Container(
      height: 40,
      padding: EdgeInsets.only(
        top: 1,
        bottom: 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            product.name,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Text(
            _formatCurrencyForList(product.price * product.quantity),
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
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


/* 
// Phone
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            top: 25.0,
                            bottom: 16,
                          ),
                        ),
                        // Payment Method
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                "Montant",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: AppColors.greenDark,
                                ),
                              ),
                            ),
                            subtitle: Text(
                              _formatCurrency(widget.order.totalAmount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.greenDark,
                              ),
                            ),
                          ),
                        ),
 */