// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_version/new_version.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/constants/app_text.dart';
import 'package:ordering_services/database/database_helper.dart';
import 'package:ordering_services/models/order.dart';
import 'package:ordering_services/models/products.dart';
import 'package:ordering_services/models/user.dart';
import 'package:ordering_services/pages/admin/admin.dart';
import 'package:ordering_services/pages/admin/payment.dart';
import 'package:ordering_services/pages/history/transaction.dart';
import 'package:ordering_services/pages/history/user_history.dart';
import 'package:ordering_services/pages/new_product.dart';
import 'package:ordering_services/pages/order_recap.dart';
import 'package:ordering_services/pages/ordering_page.dart';
import 'package:ordering_services/services/auth/auth_service.dart';
import 'package:ordering_services/services/order_service/order_service.dart';
import 'package:ordering_services/services/product_service/product_service.dart';
import 'package:ordering_services/utils/next_screen.dart';
import 'package:ordering_services/widget/button.dart';
import 'package:ordering_services/widget/network_image.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    this.newProduct,
  }) : super(key: key);
  static final String path = "lib/src/pages/ecommerce/ecommerce5.dart";
  Product newProduct;
  @override
  _HomePageState createState() => _HomePageState();

  static _HomePageState of(BuildContext context) =>
      context.findAncestorStateOfType<_HomePageState>();
}

class _HomePageState extends State<HomePage> {
  bool hideBalance = true;
  bool productAddToCart = false;
  int cartProductCount = 0;
  int currentBalance = 1000;
  double _bottom = 280;
  AuthService authService = AuthService();
  ProductService productService = ProductService();
  OrderService orderService = OrderService();

  bool _loading = true;

  final spinkit = SpinKitRing(
    color: AppColors.greenDark.withOpacity(0.5),
    lineWidth: 10.0,
    size: 100.0,
  );

  advancedStatusCheck(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();

    if (status != null) {
      debugPrint(status.releaseNotes);
      debugPrint(status.appStoreLink);
      debugPrint(status.localVersion);
      debugPrint(status.storeVersion);
      debugPrint(status.canUpdate.toString());

      if (status.canUpdate) {
        newVersion.showUpdateDialog(
          context: context,
          versionStatus: status,
          dialogTitle: 'Nouvelle Version',
          dialogText:
              'Une nouvelle version de Omega Caisse est dispoible. Veuillez télécharger la nouvelle version!',
          updateButtonText: 'Mettre à jour',
          dismissButtonText: 'Plus tard',
        );
      }
    }
  }

  void setBalance() {
    setState(() {
      print("HEREEEE setBalance");
      authService.getBalance(userId).then(
        (value) {
          currentBalance = value;
        },
      );
      getTotal();
    });
  }

  void initState() {
    super.initState();

    super.initState();
    // _read();
    // _readAll();

    print("userProfile");
    print(userProfile);
    if (userProfile == 2) {
      authService.getUsers().then(
        ((value) {
          users = value;
          getUserTotal();
        }),
      );
    } else {
      (Connectivity().checkConnectivity()).then(
        (connectivityResult) {
          if (connectivityResult == ConnectivityResult.mobile ||
              connectivityResult == ConnectivityResult.wifi) {
            final newVersion = NewVersion(
              iOSId: 'com.rasool.omegacaisse',
              androidId: 'com.rasool.omegacaisse',
            );

            advancedStatusCheck(newVersion);
            setBalance();
            print("SALUT ");

            productService.getProducts(userId).then(
              ((value) {
                products = value;
                getTotal();
              }),
            );
          } else {
            getOfflineProducts().then((value) {
              print("SALUT ");
              products = value;
              getTotal();
            });
          }
        },
      );
    }
  }

  List<Product> products = [];
  List<Product> cartProducts = [];

  List<User> users = [];

  int value = 1;
  var total = 0;

  Widget _productList(List<Product> products, context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        SizedBox(
          height: 15.0,
        ),
        Container(
          padding: EdgeInsets.only(
            right: 15.0,
            bottom: _bottom,
          ),
          width: MediaQuery.of(context).size.width - 30.0,
          height: MediaQuery.of(context).size.height,
          child: GridView.count(
            crossAxisCount: 2,
            primary: false,
            crossAxisSpacing: 6.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.71,
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
              child: ProductSelect(
                ctx: ctx,
                product: product,
              ),
            ),
          ).then(
            (value) {
              print(value);
              setState(() {
                if (value != null && product.quantity != value) {
                  product.quantity = value != null ? value : 0;
                  cartProductCount += value != null ? value : 0;
                  cartProducts.remove(product);
                  cartProducts.add(product);
                }

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
            boxShadow: [
              BoxShadow(
                color: AppColors.greenDark.withOpacity(0.1),
                blurRadius: 4.0,
                spreadRadius: 0.0,
                offset: Offset(0.0, 0.0),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 5.2,
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
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5.0),
                        topRight: Radius.circular(5.0),
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: Colors.lightBlue.shade100,
                      strokeWidth: 2.0,
                    ),
                  ),
                  errorWidget:
                      (BuildContext context, String url, dynamic error) =>
                          const Icon(Icons.error),
                ),
              ),
              SizedBox(
                height: 12.0,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 52.0,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 2.0,
                          right: 2.0,
                        ),
                        child: AutoSizeText(
                          product.name,
                          maxLines: 2,
                          maxFontSize: 15,
                          minFontSize: 15,
                          textScaleFactor: 1.5,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.greenDark,
                            decoration: TextDecoration.none,
                            fontSize: 14.5,
                            letterSpacing: 1.0,
                            wordSpacing: 1.0,
                          ),
                        ),
                        // Text(
                        //   product.name,
                        //   textScaleFactor: 1.0,
                        //   textAlign: TextAlign.justify,
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.w600,
                        //     color: AppColors.greenDark,
                        //     decoration: TextDecoration.none,
                        //     fontSize: 14.5,
                        //     overflow: TextOverflow.clip,
                        //   ),
                        // ),
                      ),
                    ),
                    SizedBox(
                      height: 48.0,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 5.0,
                          top: 12.0,
                        ),
                        child: AutoSizeText(
                          _formatCurrency(product.price.toInt()),
                          maxLines: 2,
                          maxFontSize: 15,
                          minFontSize: 15,
                          textScaleFactor: 1.0,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.greenDark,
                            decoration: TextDecoration.none,
                            fontSize: 14.5,
                            letterSpacing: 1.0,
                            wordSpacing: 1.0,
                          ),
                        ), /* Text(
                            _formatCurrency(product.price.toInt()),
                            textScaleFactor: 1.0,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.greenDark,
                              decoration: TextDecoration.none,
                              fontSize: 14.5,
                            ),
                            textAlign: TextAlign.center,
                          ), */
                      ),
                    ),
                    /* product.quantity != 0
                        ? SizedBox(
                            height: 30.0,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 5.0,
                                top: 5.0,
                              ),
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Text(
                                  "(${product.quantity})",
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.greenDark,
                                    decoration: TextDecoration.none,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        : Container(), */
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
          Product pd = Product();
          Navigator.push(
            ctx,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (ctx) => NewProductPage(
                product: pd,
              ),
            ),
          ).then((value) {
            print("The Valmue");
            print(pd);
            if (pd.name != null) {
              setState(() {
                cartProducts.add(pd);
                getTotal();
              });
              print(value);
              print(pd.name);
            } else {
              setState(() {});
            }
          });
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

  Padding _balanceWidget(context) {
    return Padding(
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
                    userProfile == 3 ? "Votre Solde" : "Solde Globale",
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
                        hideBalance
                            ? '••••••'
                            : "${_formatCurrency(currentBalance)}",
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.greenDark,
        title: Text(
          "Omega Caisse",
          style: bigBoldTextStyle(
            AppColors.greenDark,
          ),
        ),
        elevation: 0.0,
        leading: userSubscription != 0
            ? Padding(
                padding: EdgeInsets.only(
                  left: 20.0,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => AdminPage(),
                      ),
                    ).then(
                      (value) {
                        setState(() {
                          if (userProfile == 2) {
                            getUserTotal();
                          } else if (userProfile == 3) {
                            getTotal();
                          }
                        });
                      },
                    );
                  },
                  child: Icon(
                    Icons.person_outline_sharp,
                    size: 26.0,
                  ),
                ),
              )
            : Container(),
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
                            products: cartProducts,
                            total: total,
                          ),
                        ),
                      ).then(
                        (value) {
                          setState(() {
                            // currentBalance = await authService.getBalance(userId);
                            (Connectivity().checkConnectivity()).then(
                              (connectivityResult) {
                                if (connectivityResult ==
                                        ConnectivityResult.mobile ||
                                    connectivityResult ==
                                        ConnectivityResult.wifi) {
                                  authService.getBalance(userId).then(
                                    (value) {
                                      currentBalance = value;
                                    },
                                  );
                                  getTotal();
                                } else {
                                  _getOfflineBalance();
                                  getTotal();
                                }
                              },
                            );

                            _loading = false;
                          });
                          // setState(() {
                          //   authService.getBalance(userId).then(
                          //     (value) {
                          //       currentBalance = value;
                          //     },
                          //   );
                          // });
                          setState(() {});
                        },
                      );
                    },
                    child: Stack(
                      overflow: Overflow.visible,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            size: 26.0,
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 1,
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: AppColors.greenDark,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 0.5,
                                color: AppColors.greenDark,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "$cartProductCount",
                                style: TextStyle(
                                  fontSize: 10,
                                  height: 1,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
      backgroundColor: userSubscription == 0 ? Colors.white70 : Colors.white,
      body: _loading
          ? spinkit
          : SafeArea(
              child: Stack(
                children: <Widget>[
                  userSubscription == 0
                      ? Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ), //this right here
                          child: Container(
                            height: 350,
                            width: 320,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Center(
                                    child: Text(
                                      "Votre abonnement a expiré, veuillez procéder au paiement des 5.000 FCFA!",
                                      style: TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 24.0,
                                          right: 0,
                                          left: 0,
                                        ),
                                        child: FlatButton(
                                          onPressed: () async {
                                            // Navigator.of(context).pop();
                                            showModalBottomSheet(
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              context: context,
                                              builder: (context) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(24),
                                                      topLeft:
                                                          Radius.circular(24),
                                                    ),
                                                  ),
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 250,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 40,
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 40,
                                                            bottom: 20.0,
                                                          ),
                                                          child: Text(
                                                            "Payer votre abonnement de 5.000 FCFA avec :",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();

                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (_,
                                                                            __,
                                                                            ___) =>
                                                                        PaymentPage(
                                                                      wallet: 1,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Material(
                                                                elevation: 5,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .all(
                                                                  Radius
                                                                      .circular(
                                                                          50),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  height: 85,
                                                                  width: 85,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .all(
                                                                      Radius.circular(
                                                                          50),
                                                                    ),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: AppColors
                                                                            .greenDark
                                                                            .withOpacity(0.1),
                                                                        blurRadius:
                                                                            4.0,
                                                                        spreadRadius:
                                                                            0.0,
                                                                        offset: Offset(
                                                                            0.0,
                                                                            0.0),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            5.0),
                                                                    child:
                                                                        Image(
                                                                      image:
                                                                          AssetImage(
                                                                        "assets/logo-part/orange-money.png",
                                                                      ),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 40.0,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (_,
                                                                            __,
                                                                            ___) =>
                                                                        PaymentPage(
                                                                      wallet: 2,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Material(
                                                                elevation: 5,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .all(
                                                                  Radius
                                                                      .circular(
                                                                          50),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  height: 85,
                                                                  width: 85,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .all(
                                                                      Radius.circular(
                                                                          50),
                                                                    ),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: AppColors
                                                                            .greenDark
                                                                            .withOpacity(0.1),
                                                                        blurRadius:
                                                                            4.0,
                                                                        spreadRadius:
                                                                            0.0,
                                                                        offset: Offset(
                                                                            0.0,
                                                                            0.0),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            5.0),
                                                                    child:
                                                                        Image(
                                                                      image:
                                                                          AssetImage(
                                                                        "assets/logo-part/wave.png",
                                                                      ),
                                                                      fit: BoxFit
                                                                          .cover,
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
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(10.0),
                                            height: 40.5,
                                            width: 180,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              color: Colors.red.withOpacity(.3),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Payer maintenant",
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w400,
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
                        )
                      : Column(
                          children: <Widget>[
                            _balanceWidget(context),
                            Expanded(
                              child: userProfile == 3
                                  ? _productList(
                                      products,
                                      context,
                                    )
                                  : userProfile == 2
                                      ? _userList(
                                          users,
                                          context,
                                        )
                                      : Container(),
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
                                  width:
                                      MediaQuery.of(context).size.width / 2.3,
                                  child: DefaultButton(
                                    text: "Valider la commande",
                                    press: () async {
                                      setState(() {
                                        _loading = true;
                                      });
                                      var result = Order();
                                      var connectivityResult =
                                          await (Connectivity()
                                              .checkConnectivity());
                                      if (connectivityResult ==
                                              ConnectivityResult.mobile ||
                                          connectivityResult ==
                                              ConnectivityResult.wifi) {
                                        // I am connected to a mobile network.
                                        print(
                                            "I am connected to a mobile network");

                                        print(
                                            "I am connected to a wifi network");
                                        // result = await createOrder();
                                        // print(result.ref);

                                        result = await orderService.newOrder(
                                            total, cartProducts);

                                        // I am connected to a wifi network.
                                      } else {
                                        print("We don't have connection");

                                        result = await createOrder();
                                      }

                                      print(result);

                                      if (result != null) {
                                        // currentBalance = await authService
                                        //     .getBalance(userId);

                                        setState(() {
                                          products.forEach((product) {
                                            product.quantity = 0;
                                          });
                                          cartProducts.clear();
                                          getTotal();
                                          _loading = false;
                                        });

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            fullscreenDialog: true,
                                            builder: (context) => OrderPage(
                                              order: result,
                                            ),
                                          ),
                                        ).then((value) {
                                          setState(() {
                                            // currentBalance = await authService.getBalance(userId);
                                            (Connectivity().checkConnectivity())
                                                .then(
                                              (connectivityResult) {
                                                if (connectivityResult ==
                                                        ConnectivityResult
                                                            .mobile ||
                                                    connectivityResult ==
                                                        ConnectivityResult
                                                            .wifi) {
                                                  authService
                                                      .getBalance(userId)
                                                      .then(
                                                    (value) {
                                                      currentBalance = value;
                                                    },
                                                  );
                                                } else {
                                                  _getOfflineBalance();
                                                  getTotal();
                                                }
                                              },
                                            );

                                            _loading = false;
                                          });
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
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ), //this right here
                                              child: Container(
                                                height: 250,
                                                width: 320,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                        child: Icon(
                                                          Icons
                                                              .warning_amber_rounded,
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
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              top: 24.0,
                                                              right: 0,
                                                              left: 0,
                                                            ),
                                                            child: FlatButton(
                                                              onPressed:
                                                                  () async {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10.0),
                                                                height: 40.5,
                                                                width: 110,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                  color: Colors
                                                                      .red
                                                                      .withOpacity(
                                                                          .3),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    "Ok",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14.0,
                                                                      color: Colors
                                                                          .red,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
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

  Widget _userList(List<User> users, context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        SizedBox(
          height: 15.0,
        ),
        users.isEmpty
            ? Padding(
                padding: EdgeInsets.only(
                  right: 16.0,
                  left: 16.0,
                  top: 36.0,
                ),
                child: Container(
                  // width: 220,
                  height: 200,
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
                        child: Text(
                          "Aucun agent pour le moment !",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            // color: gray.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(
                  right: 16.0,
                  left: 16.0,
                  top: 36.0,
                ),
                child: Container(
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
                    itemCount: users.length,
                    itemBuilder: (BuildContext context, int index) {
                      User user = users[index];
                      return _buildUserList(
                        user,
                        context,
                        index == users.length - 1,
                      );
                    },
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildUserList(
    User user,
    BuildContext context,
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
          _userItem(context, user),
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

  Widget _userItem(BuildContext context, User user) {
    return InkWell(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => UserHistoryPage(
              user: user,
            ),
          ),
        ).then((value) {
          if (userProfile == 2) {
            getUserTotal();
          } else if (userProfile == 3) {
            getTotal();
          }
        });
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
                  user.name,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  user.phone,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  _formatCurrency(user.balance),
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void getUserTotal() async {
    var balance = 0;
    users.forEach((user) {
      balance += user.balance;
    });

    setState(() {
      currentBalance = balance;
      _loading = false;
    });
  }

  void getTotal() async {
    total = 0;
    _bottom = 0;
    cartProductCount = 0;
    cartProducts.forEach((product) {
      total += product.price.toInt() * product.quantity;
      if (product.quantity > 0) {
        cartProductCount += product.quantity;
      } else {
        setState(() {
          cartProducts.remove(product);
          cartProductCount += 0;
        });
      }
    });

    productAddToCart = total != 0 ? true : false;
    _bottom = total != 0 ? 330 : 270;
    setState(() {
      // currentBalance = await authService.getBalance(userId);
      (Connectivity().checkConnectivity()).then(
        (connectivityResult) {
          if (connectivityResult == ConnectivityResult.mobile ||
              connectivityResult == ConnectivityResult.wifi) {
            authService.getBalance(userId).then(
              (value) {
                currentBalance = value;
              },
            );
          } else {
            _getOfflineBalance();
          }
        },
      );

      _loading = false;
    });
  }

  Future<List<Product>> getOfflineProducts() async {
    DatabaseHelper helper = DatabaseHelper.instance;

    List<Product> products = await helper.queryAllProducts();
    if (products == null) {
      print('read row $products: empty');
      return [];
    } else {
      print('read row: ${products.length}');
      return products;
    }
  }

  _getOfflineBalance() async {
    DatabaseHelper helper = DatabaseHelper.instance;

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var bal = _prefs.getInt("currentBalance");
    print("bal");
    print(bal);
    var day = _formatDate(DateTime.now());
    TimeOfDay now = TimeOfDay.now();
    print(now.hour < 4);
    TimeOfDay releaseTime = TimeOfDay(hour: 4, minute: 59);

    var h = now.hour > 10 ? now.hour : "0${now.hour}";
    var m = now.minute > 10 ? now.minute : "0${now.minute}";

    var endDate = "$day $h:$m:59";
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

    print("startDate");
    print("endDate");

    print(startDate);
    print(endDate);

    List<Order> orders = await helper.queryAllOrders();
    orders = orders.where((Order order) {
      var date = DateTime.parse(order.date);

      var startDay = DateTime.parse(startDate);

      var endDay = DateTime.parse(endDate);
      return date.isAfter(startDay) && date.isBefore(endDay);
    }).toList();
    orders.forEach((order) {
      bal += order.totalAmount;
    });
    print("bal");
    print(bal);
    setState(() {
      currentBalance = bal;
    });
  }

  Future<Order> createOrder() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    final order = await helper.insertOrder(cartProducts);
    print('inserted row: ${order.ref}');
    return order;
  }

  /* _read() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/omegacaisse.txt');
      String text = await file.readAsString();
      print(text);
    } catch (e) {
      print("Couldn't read file");
    }
  }

  _save() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/omegacaisse.txt');
    final text = 'Hello World!';
    await file.writeAsString(text);
    print('saved');
  } */
}

String _formatCurrency(int amount) {
  var f = new NumberFormat.currency(
    locale: "fr",
    symbol: "F",
    decimalDigits: 0,
    customPattern: '#,### \u00a4',
  );
  return '${f.format(amount)}';
}

String _formatDate(DateTime date) {
  final format = DateFormat('yyyy-MM-dd');
  return format.format(date);
}
