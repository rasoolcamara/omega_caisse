// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/constants/app_text.dart';
import 'package:ordering_services/models/products.dart';

class OrderRecap extends StatefulWidget {
  final List<Product> products;
  final int total;
  const OrderRecap({Key key, this.products, this.total}) : super(key: key);

  @override
  _OrderRecapState createState() => _OrderRecapState();
}

class _OrderRecapState extends State<OrderRecap> {
  var total = 0;

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
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            for (int i = 0; i < widget.products.length; i++)
              widget.products[i].quantity > 0
                  ? _productBuild(context, widget.products[i])
                  : SizedBox(),
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
                  color:
                      total != 0 ? AppColors.greenDark : Colors.grey.shade500,
                  onPressed: () {},
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
          imageUrl: product.image,
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
    widget.products.forEach((product) {
      total +=
          product.quantity > 0 ? product.price.toInt() * product.quantity : 0;
    });
  }
}

String _formatCurrency(int amount) {
  var f = new NumberFormat.currency(
      locale: "fr-FR", symbol: "Fcfa", decimalDigits: 0);
  return '${f.format(amount)}';
}
