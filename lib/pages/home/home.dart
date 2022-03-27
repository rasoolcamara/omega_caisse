// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/constants/app_text.dart';
import 'package:ordering_services/models/products.dart';
import 'package:ordering_services/pages/admin/admin.dart';
import 'package:ordering_services/pages/new_product.dart';
import 'package:ordering_services/pages/order_recap.dart';
import 'package:ordering_services/pages/ordering_page.dart';
import 'package:ordering_services/utils/next_screen.dart';
import 'package:ordering_services/widget/button.dart';
import 'package:ordering_services/widget/network_image.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);
  static final String path = "lib/src/pages/ecommerce/ecommerce5.dart";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool hideBalance = true;
  bool productAddToCart = false;
  int cartProductCount = 0;

  @override
  void initState() {
    super.initState();
    getTotal();
  }

  List<Product> products = [
    Product(
        id: 1,
        name: 'Hamburger',
        image:
            'https://firebasestorage.googleapis.com/v0/b/dl-flutter-ui-challenges.appspot.com/o/food%2Fburger.jpg?alt=media',
        price: 1300,
        quantity: 0),
    Product(
        id: 2,
        name: 'Shawarma',
        image:
            'https://firebasestorage.googleapis.com/v0/b/dl-flutter-ui-challenges.appspot.com/o/food%2Fburger.jpg?alt=media',
        price: 1400,
        quantity: 0),
    Product(
        id: 3,
        name: 'Pizza',
        image:
            'https://firebasestorage.googleapis.com/v0/b/dl-flutter-ui-challenges.appspot.com/o/food%2Fburger.jpg?alt=media',
        price: 3000,
        quantity: 0),
    Product(
        id: 4,
        name: 'Riz blanc',
        image:
            'https://firebasestorage.googleapis.com/v0/b/dl-flutter-ui-challenges.appspot.com/o/food%2Fburger.jpg?alt=media',
        price: 1000,
        quantity: 0),
    Product(
        id: 5,
        name: 'Ananas',
        image:
            'https://firebasestorage.googleapis.com/v0/b/dl-flutter-ui-challenges.appspot.com/o/food%2Fburger.jpg?alt=media',
        price: 1500,
        quantity: 0)
  ];

  int value = 1;
  var total = 0;

  Widget _productList(List<Product> products, context) {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 15.0,
        ),
        Container(
          padding: EdgeInsets.only(right: 15.0),
          width: MediaQuery.of(context).size.width - 30.0,
          height: MediaQuery.of(context).size.height,
          child: GridView.count(
            crossAxisCount: 2,
            primary: false,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 25.0,
            childAspectRatio: 0.8,
            children: List.generate(
              products.length + 1,
              (index) {
                if (index < products.length) {
                  Product product = products[index];
                  return _buildCard(product, context);
                } else {
                  return cardNewProduct(
                    context,
                  );
                }
              },
            ),
          ),
        ),
        // SizedBox(
        //   height: 15.0,
        // ),
      ],
    );
  }

  Widget _buildCard(Product product, context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 5.0,
        bottom: 5.0,
        left: 20.0,
        right: 5.0,
      ),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            elevation: 10,
            backgroundColor: Colors.white,
            context: context,
            builder: (ctx) => Container(
              width: 300,
              height: 270,
              color: Colors.white54,
              alignment: Alignment.center,
              child: ProductSelect(ctx: ctx, product: product),
            ),
          ).then(
            (value) {
              setState(() {
                product.quantity = value;
                cartProductCount += value;

                getTotal();
              });
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
            color: AppColors.green.withOpacity(.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 115.0,
                width: MediaQuery.of(context).size.width / 1.5,
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  imageBuilder:
                      (BuildContext context, ImageProvider imageProvider) =>
                          Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.fill,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 0.0,
                          color: Colors.black87,
                        )
                      ],
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1E2026),
                          Color(0xFF23252E),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: Colors.lightBlue.shade100,
                    ),
                  ),
                  errorWidget:
                      (BuildContext context, String url, dynamic error) =>
                          const Icon(Icons.error),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.greenDark,
                        decoration: TextDecoration.none,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      _formatCurrency(product.price.toInt()),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.greenDark,
                        decoration: TextDecoration.none,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    product.quantity != 0
                        ? Text(
                            "(${product.quantity})",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.greenDark,
                              decoration: TextDecoration.none,
                              fontSize: 12,
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 5.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardNewProduct(ctx) {
    return Padding(
      padding: EdgeInsets.only(
        top: 5.0,
        bottom: 5.0,
        left: 20.0,
        right: 5.0,
      ),
      child: InkWell(
        onTap: () {
          nextScreenPopup(
            ctx,
            NewProductPage(),
          );
        },
        child: Container(
          height: 100,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
            color: AppColors.green.withOpacity(.2),
          ),
          child: Icon(
            Icons.add,
            size: 64,
            color: AppColors.greenDark,
          ),
        ),
      ),
    );

    /*  Container(
      height: 200,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 6.0,
          ),
        ],
        color: Colors.white,
      ),
      child: GestureDetector(
        onTap: () {
          nextScreenPopup(ctx, NewProductPage());
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add,
                size: 64,
                color: AppColors.PRIMARY_COLOR,
              ),
            ],
          ),
        ),
      ),
    ); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.greenDark,
        title: Text(
          "Ordering",
          style: bigBoldTextStyle(
            AppColors.greenDark,
          ),
        ),
        elevation: 0.0,
        leading: Padding(
          padding: EdgeInsets.only(
            left: 20.0,
          ),
          child: GestureDetector(
            onTap: () {
              nextScreenPopup(
                context,
                AdminPage(),
              );
            },
            child: Icon(
              Icons.person_outline_sharp,
              size: 26.0,
            ),
          ),
        ),
        actions: [
          total != 0
              ? Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => OrderRecap(
                            products: products,
                            total: total,
                          ),
                        ),
                      ).then(
                        (value) {
                          setState(() {
                            // product.quantity = value;
                            // cartProductCount += value;
                            // productAddToCart = true;
                            getTotal();
                          });
                        },
                      );
                      // nextScreenPopup(
                      //   context,
                      //   OrderRecap(
                      //     products: products,
                      //     total: total,
                      //   ),
                      // );
                    },
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 26.0,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 16.0,
                    left: 16.0,
                    top: 16.0,
                  ),
                  child: Container(
                    // width: 220,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      // image: DecorationImage(image: AssetImage(paymentMethod.logo)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFABABAB).withOpacity(0.2),
                          blurRadius: 4.0,
                          spreadRadius: 3.0,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Votre Solde",
                                style: regularLightTextStyle(
                                  AppColors.greenDark,
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    hideBalance ? '••••••' : "$total fcfa",
                                    style: bigBoldTextStyle(
                                      AppColors.greenDark,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 20.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          hideBalance = !hideBalance;
                                        });
                                      },
                                      child: Icon(
                                        !hideBalance
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 26.0,
                                        color: AppColors.greenDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _productList(
                    products,
                    context,
                  ),
                ),
              ],
            ),
            productAddToCart
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 16.0,
                        bottom: 5.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      // height: 174,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, -15),
                            blurRadius: 20,
                            color: Colors.black.withOpacity(0.09),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: _formatCurrency(total) + "\n",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.greenDark,
                                fontSize: 16,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      "$cartProductCount élements dans le panier",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.greenDark,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 170,
                            child: DefaultButton(
                              text: "Valider la commande",
                              press: () {
                                // nextScreenPopup(
                                //   context,
                                //   OrderRecap(
                                //     products: products,
                                //     total: total,
                                //   ),
                                // );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void getTotal() {
    total = 0;
    cartProductCount = 0;
    products.forEach((product) {
      total +=
          product.quantity > 0 ? product.price.toInt() * product.quantity : 0;
      cartProductCount += product.quantity > 0 ? product.quantity : 0;
    });

    productAddToCart = total != 0 ? true : false;
  }
}

String _formatCurrency(int amount) {
  var f = new NumberFormat.currency(
      locale: "fr-FR", symbol: "Fcfa", decimalDigits: 0);
  return '${f.format(amount)}';
}
