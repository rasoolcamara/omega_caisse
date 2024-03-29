// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/constants/app_text.dart';
import 'package:ordering_services/models/products.dart';
import 'package:ordering_services/pages/new_product.dart';
import 'package:ordering_services/pages/order_recap.dart';
import 'package:ordering_services/services/product_service/product_service.dart';
import 'package:ordering_services/utils/next_screen.dart';
import 'package:ordering_services/widget/network_image.dart';

class EcommerceFivePage extends StatefulWidget {
  const EcommerceFivePage({Key key}) : super(key: key);
  static final String path = "lib/src/pages/ecommerce/ecommerce5.dart";

  @override
  _EcommerceFivePageState createState() => _EcommerceFivePageState();
}

class _EcommerceFivePageState extends State<EcommerceFivePage> {
  ProductService productService = ProductService();

  bool _loading = false;

  final spinkit = SpinKitRing(
    color: AppColors.greenDark.withOpacity(0.5),
    lineWidth: 10.0,
    size: 100.0,
  );

  @override
  void initState() {
    super.initState();
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

  Widget cards(ctx, Product product) {
    return Container(
      height: 200,
      width: 200,
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
          showModalBottomSheet(
            elevation: 10,
            isScrollControlled: true,
            // isDismissible: false,
            backgroundColor: Colors.white,
            context: ctx,
            builder: (ctx) => ProductSelect(
              ctx: ctx,
              product: product,
            ),
          ).then(
            (value) {
              setState(() {
                product.quantity = value;
                getTotal();
              });
            },
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              PNetworkImage(
                "https://omega.dohappit.com/" + product.image,
                height: 80,
                fit: BoxFit.fill,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                product.name,
                style: regularLightTextStyle(
                  Colors.black,
                ),
              ),
              Text(product.quantity.toString()),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                margin: EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.ACCENT_COLOR_DARK,
                ),
                child: Text(
                  " ${product.price.toInt()} cfa",
                  style: mediumLightTextStyle(
                    Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardNewProduct(ctx) {
    return Container(
      height: 200,
      width: 200,
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
          nextScreenPopup(context, NewProductPage());
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "7800 Fcfa",
          style: bigBoldTextStyle(
            Colors.white,
          ),
        ),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text(
                'Item 1',
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                'Item 2',
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white70.withOpacity(0.9),
      body: FutureBuilder(
        future: productService.getProducts(activeUser.id),
        builder: (_, snapshot) {
          if (snapshot.data != null) {
            List<Product> products = snapshot.data;
            return SafeArea(
              child: Stack(
                children: <Widget>[
                  CustomScrollView(
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 50),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(26.0),
                        sliver: SliverGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          children: <Widget>[
                            for (int i = 0; i < products.length; i++)
                              cards(context, products[i]),
                            cardNewProduct(
                              context,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Card(
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      height: 130,
                      padding: EdgeInsets.all(4),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Commande en cours",
                                style: regularLightTextStyle(
                                    AppColors.PRIMARY_COLOR),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    nextScreenPopup(
                                      context,
                                      OrderRecap(
                                        products: products,
                                        total: total,
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.add,
                                    size: 32,
                                  ))
                            ],
                          ),
                          // SizedBox(height: 4,),
                          // for (int i = 0; i < 3; i++)
                          //   products[i].quantity  > 0 ?  Padding(
                          //     padding: const EdgeInsets.all(2.0),
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //       children: [
                          //         Container(
                          //             width: 100,
                          //             child: Text("${products[i].name} : ${products[i].quantity}", style: mediumLightTextStyle(AppColors.ACCENT_COLOR),)),
                          //
                          //         Text("${(products[i].quantity * products[i].price.toInt())} fcfa"),
                          //       ],
                          //     ),
                          //   ): SizedBox(),
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Total:",
                                style: regularLightTextStyle(
                                    AppColors.PRIMARY_COLOR),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "$total FCFA",
                                style: regularBoldTextStyle(
                                    AppColors.PRIMARY_COLOR),
                              ),
                            ],
                          ),
                          RaisedButton(
                            color: AppColors.PRIMARY_COLOR,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0))),
                            child: Text(
                              "Valider la commande",
                              style: mediumLightTextStyle(Colors.white),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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

  void getTotal() {
    total = 0;
    products.forEach((product) {
      total += product.price.toInt() * product.quantity;
    });
  }
}

class ProductSelect extends StatefulWidget {
  final Product product;
  final BuildContext ctx;

  const ProductSelect({Key key, this.product, this.ctx}) : super(key: key);

  @override
  _ProductSelectState createState() => _ProductSelectState();
}

class _ProductSelectState extends State<ProductSelect> {
  int value = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        bottom: 20,
        left: 10,
        right: 10,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.product.name,
                style: TextStyle(
                  color: AppColors.greenDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "${widget.product.price.toInt()} FCFA",
                style: TextStyle(
                  color: AppColors.greenDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            margin: EdgeInsets.only(
              bottom: 45,
            ),
            child: NumberPicker.horizontal(
              initialValue: value,
              minValue: 1,
              maxValue: 100,
              step: 1,
              zeroPad: false,
              onChanged: (values) {
                print(values);
                setState(() {
                  value = values;
                });
              },
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.greenDark,
                ),
                color: AppColors.green.withOpacity(.3),
              ),
              selectedTextStyle: TextStyle(
                color: AppColors.greenDark,
                fontSize: 24,
              ),
              textStyle: TextStyle(
                color: Colors.black45,
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              right: 8,
              left: 8,
              bottom: 24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Sous-total:",
                  style: TextStyle(
                    color: AppColors.greenDark,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "${widget.product.price.toInt() * value} FCFA",
                  style: TextStyle(
                    color: AppColors.greenDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            height: 40,
            child: RaisedButton(
              color: AppColors.greenDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              child: Text(
                "Valider",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pop(widget.ctx, value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
