// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/constants/app_text.dart';
import 'package:ordering_services/database/database_helper.dart';
import 'package:ordering_services/models/order.dart';
import 'package:ordering_services/models/products.dart';
import 'package:ordering_services/pages/history/transaction.dart';
import 'package:ordering_services/pages/home/home.dart';
import 'package:ordering_services/services/order_service/order_service.dart';
import 'package:ordering_services/utils/next_screen.dart';

class OrderRecap extends StatefulWidget {
  final List<Product> products;
  final int total;
  const OrderRecap({
    Key key,
    this.products,
    this.total,
  }) : super(key: key);

  @override
  _OrderRecapState createState() => _OrderRecapState();
}

class _OrderRecapState extends State<OrderRecap> {
  var total = 0;

  OrderService orderService = OrderService();

  bool _loading = false;

  final spinkit = SpinKitRing(
    color: AppColors.greenDark.withOpacity(0.5),
    lineWidth: 10.0,
    size: 100.0,
  );

  @override
  void initState() {
    super.initState();
    getTotal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.greenDark,
        title: Text(
          "Panier",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
            decoration: TextDecoration.none,
            fontSize: 20,
          ),
        ),
        elevation: 0.0,
      ),
      body: _loading
          ? spinkit
          : Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  for (int i = 0; i < widget.products.length; i++)
                    _productBuild(context, widget.products[i]),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 16.0,
                      bottom: 5.0,
                      left: 26.0,
                      right: 40.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total",
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          _formatCurrency(total),
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  Center(
                    child: SizedBox(
                      width: 250,
                      height: 50,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        color: total != 0
                            ? AppColors.greenDark
                            : Colors.grey.shade500,
                        onPressed: () async {
                          if (total != 0) {
                            setState(() {
                              _loading = true;
                            });
                            var result = Order();
                            var connectivityResult =
                                await (Connectivity().checkConnectivity());
                            if (connectivityResult ==
                                    ConnectivityResult.mobile ||
                                connectivityResult == ConnectivityResult.wifi) {
                              // I am connected to a mobile network.
                              print("I am connected to a mobile network");

                              print("I am connected to a wifi network");
                              result = await orderService.newOrder(
                                total,
                                widget.products,
                              );

                              // I am connected to a wifi network.
                            } else {
                              print("We don't have connection");

                              result = await createOrder();
                            }
                            print(result);

                            if (result != null) {
                              setState(() {
                                widget.products.forEach((product) {
                                  product.quantity = 0;
                                });
                                widget.products.clear();
                                getTotal();
                                _loading = false;
                              });
                              // Navigator.pop(context);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  fullscreenDialog: true,
                                  builder: (context) => OrderPage(
                                    order: result,
                                  ),
                                ),
                              ).then((value) {
                                // HomePage.of(context).setBalance();

                                Navigator.pop(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                  ),
                                );
                              });
                            } else {
                              setState(() {
                                _loading = false;
                              });
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ), //this right here
                                    child: Container(
                                      height: 250,
                                      width: 320,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Align(
                                              child: Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.red,
                                                size: 64,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 16,
                                            ),
                                            Text(
                                              "Une erreur s'est produite, veuillez réessayer !",
                                              style: TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 24.0,
                                                    right: 0,
                                                    left: 0,
                                                  ),
                                                  child: FlatButton(
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(10.0),
                                                      height: 40.5,
                                                      width: 110,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        color: Colors.red
                                                            .withOpacity(.3),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "Ok",
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        },
                        child: Text(
                          "Valider la commande",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _productBuild(context, Product product) {
    return Padding(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 1.0),
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: "https://omega.dohappit.com/" + product.image ??
              'assets/logo-part/emoney.png',
          imageBuilder: (BuildContext context, ImageProvider imageProvider) =>
              Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
          ),
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              color: Colors.lightBlue.shade100,
            ),
          ),
          errorWidget: (BuildContext context, String url, dynamic error) =>
              const Icon(Icons.error),
        ),
        title: Padding(
          padding: const EdgeInsets.only(
            top: 5.0,
            bottom: 5.0,
            right: 1.0,
          ),
          child: Text(
            product.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
        subtitle: Text(
          "${product.quantity}" +
              "  x  " +
              _formatCurrency(product.price.toInt()),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        trailing: IconButton(
          padding: const EdgeInsets.all(.0),
          onPressed: () {
            setState(() {
              product.quantity = 0;
              widget.products.remove(product);
              getTotal();
            });
          },
          color: Colors.red.withOpacity(.8),
          iconSize: 25,
          icon: Icon(
            Icons.delete,
          ),
        ),
      ),
    );
  }

  void getTotal() {
    total = 0;
    widget.products.forEach(
      (product) {
        total +=
            product.quantity > 0 ? product.price.toInt() * product.quantity : 0;
      },
    );
  }

  Future<Order> createOrder() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    final order = await helper.insertOrder(widget.products);
    print('inserted row: ${order.ref}');
    return order;
  }
}

String _formatCurrency(int amount) {
  var f = new NumberFormat.currency(
      locale: "fr-FR", symbol: "Fcfa", decimalDigits: 0);
  return '${f.format(amount)}';
}
