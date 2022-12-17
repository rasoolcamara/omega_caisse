// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_version/new_version.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/constants/app_text.dart';
import 'package:ordering_services/database/database_helper.dart';
import 'package:ordering_services/models/app_setting.dart';
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
import 'package:ordering_services/services/softPay/wave.dart';
import 'package:ordering_services/utils/next_screen.dart';
import 'package:ordering_services/widget/button.dart';
import 'package:ordering_services/widget/network_image.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  final TextEditingController _searchController = TextEditingController();
  final WaveService waveService = WaveService();

  bool _loading = true;

  bool _paymentLoading = false;

  bool payed = false;

  int _timer = 1;

  final spinkit = SpinKitRing(
    color: AppColors.greenDark.withOpacity(0.5),
    lineWidth: 10.0,
    size: 100.0,
  );

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        backgroundColor: AppColors.green,
        content: new Text(
          message,
          style: new TextStyle(
            color: AppColors.greenDark,
          ),
          textAlign: TextAlign.center,
        ),
        duration: duration,
      ),
    );
  }

  bool canUpdate(PackageInfo packageInfo, AppSetting appSetting) {
    print("packageInfo.version");
    print(packageInfo.version);

    final local = packageInfo.version.split('.').map(int.parse).toList();
    final store = appSetting.currentVersion.split('.').map(int.parse).toList();

    // Each consecutive field in the version notation is less significant than the previous one,
    // therefore only one comparison needs to yield `true` for it to be determined that the store
    // version is greater than the local version.
    for (var i = 0; i < store.length; i++) {
      // The store version field is newer than the local version.
      if (store[i] > local[i]) {
        return true;
      }

      // The local version field is newer than the store version.
      if (local[i] > store[i]) {
        return false;
      }
    }

    // The local and store versions are the same.
    return false;
  }

  versionStatusCheck() async {
    AppSetting appVersion = await ProductService().getAppSetting();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    NewVersion();
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    print("canUpdate");
    bool canUpdateApp =
        appVersion != null ? canUpdate(packageInfo, appVersion) : true;
    print(canUpdateApp);
    if (canUpdateApp) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Material(
            type: MaterialType.transparency,
            child: Container(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: ScreenUtil().setHeight(10),
                    ),
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.green,
                      size: 50,
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(10),
                    ),
                    Text(
                      "NOUVELLE VERSION!",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(14),
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Divider(),
                    Text(
                      "Une nouvelle version de OMEGA CAISSE est disponible. Veuillez procéder à la mise à jour!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(12),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(40),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: ScreenUtil().setWidth(130),
                          child: FlatButton(
                            splashColor: Colors.white,
                            highlightColor: Colors.white,
                            hoverColor: Colors.white,
                            focusColor: Colors.white,
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              height: ScreenUtil().setHeight(40.5),
                              // width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: AppColors.red.withOpacity(0.08),
                              ),
                              child: Center(
                                child: Text(
                                  "Plus tard",
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(12),
                                    color: AppColors.red,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(
                                context,
                                true,
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(150),
                          child: FlatButton(
                            splashColor: Colors.white,
                            highlightColor: Colors.white,
                            hoverColor: Colors.white,
                            focusColor: Colors.white,
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              height: ScreenUtil().setHeight(40.5),
                              // width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: AppColors.green.withOpacity(0.4),
                              ),
                              child: Center(
                                child: Text(
                                  "Mettre à jour",
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(12),
                                    color: AppColors.greenDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              print("On appelle le callback");
                              if (await canLaunch(playStoreUrl)) {
                                await launch(playStoreUrl);
                              } else {
                                show(
                                  "Nous ne parvennons pas à ouvrir Play Store!",
                                  duration: Duration(seconds: 5),
                                );
                              }

                              Navigator.pop(
                                context,
                                true,
                              );
                            },
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

  void setBalance() {
    setState(() {
      print("HEREEEE setBalance");
      authService.getBalance(userId).then(
        (value) {
          currentBalance = value;
        },
      );
      offlineTooLong = false;
      getTotal();
    });
  }

  void initState() {
    super.initState();

    final cron = Cron();

    cron.schedule(Schedule.parse('* * * 1-5 */1 *'), () async {
      (Connectivity().checkConnectivity()).then(
        (connectivityResult) async {
          if (connectivityResult == ConnectivityResult.mobile ||
              connectivityResult == ConnectivityResult.wifi) {
            SharedPreferences _prefs = await SharedPreferences.getInstance();
            var code = _prefs.getString('code');
            AuthService authService = AuthService();

            final user = await authService.login(
              userPhone,
              code,
            );
          } else {
            var now = DateTime.now();
            print("On Updates les données user");
            if (now.day < 5) {
              setState(() {
                print("On Updates les données user 1111");

                userSubscription = 2;
              });
            } else {
              setState(() {
                print("On Updates les données user 2222");

                userSubscription = 0;
              });
            }
          }
        },
      );

      setState(() {});
    });

    (Connectivity().checkConnectivity()).then((connectivityResult) async {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
          try {
            print('gfqhdfw');
            versionStatusCheck();

            print('advancedStatusCheck');
          } catch (e) {
            print("errorrrrrr");
            print(e);
          }
        }
      }
    });

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
            // final newVersion = NewVersion(
            //   iOSId: 'com.omegatech.omegacaisse',
            //   androidId: 'com.omegatech.omegacaisse',
            // );

            // advancedStatusCheck(newVersion);
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
  bool _searching = false;
  List<Product> searchingProducts = [];
  List<User> users = [];

  int value = 1;
  var total = 0;

  Widget _productList(List<Product> prods, context) {
    if (prods.length != 0 && prods.last.id != -1) {
      prods.add(
        Product(id: -1),
      );
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > 600) {
          return ListView(
            // physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              SizedBox(
                height: 15.0,
              ),
              products.length > 15 ? _search(context, products) : Container(),
              Container(
                padding: EdgeInsetsDirectional.only(
                  // start: 4,
                  top: 20,
                  bottom: (cartProductCount == 0) ? 20 : 80,
                ),
                child: Wrap(
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  children: prods.map((Product product) {
                    print(prods.indexOf(product));
                    if (product.id != -1) {
                      return FractionallySizedBox(
                        widthFactor: 0.3,
                        child: Container(
                          padding: const EdgeInsetsDirectional.only(end: 16),
                          child: _buildCard(product, context),
                        ),
                      );
                    } else {
                      return FractionallySizedBox(
                        widthFactor: 0.3,
                        child: Container(
                          padding: const EdgeInsetsDirectional.only(end: 16),
                          child: cardNewProduct(context),
                        ),
                      );
                    }
                  }).toList(),
                ),
                /* GridView.count(
            crossAxisCount: 2,
            primary: false,
            crossAxisSpacing: 6.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.71,
            children: List.generate(
              prods.length + 1,
              (index) {
                if (index < prods.length) {
                  Product product = prods[index];
                  return _buildCard(product, context);
                } else {
                  return cardNewProduct(
                    context,
                  );
                }
              },
            ),
          ), */
              ),
            ],
          );
        } else {
          return ListView(
            // physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              SizedBox(
                height: 15.0,
              ),
              products.length > 15 ? _search(context, products) : Container(),
              Container(
                padding: EdgeInsetsDirectional.only(
                  // start: 4,
                  top: 20,
                  bottom: (cartProductCount == 0) ? 20 : 80,
                ),
                child: Wrap(
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  children: prods.map((Product product) {
                    if (product.id != -1) {
                      return FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          padding: const EdgeInsetsDirectional.only(end: 16),
                          child: _buildCard(product, context),
                        ),
                      );
                    } else {
                      return FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          padding: const EdgeInsetsDirectional.only(end: 16),
                          child: cardNewProduct(context),
                        ),
                      );
                    }
                  }).toList(),
                ),
              ),
            ],
          );
        }
      },
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
          setState(() {
            _searching = false;
            _searchController.clear();
          });
          showModalBottomSheet(
            elevation: 10,
            backgroundColor: Colors.white,
            context: context,
            builder: (ctx) => Container(
              width: ScreenUtil().setWidth(300),
              height: ScreenUtil().setHeight(270),
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
                height: MediaQuery.of(context).size.height / 6.5,
                width: MediaQuery.of(context).size.width / 1.5,
                child: CachedNetworkImage(
                  imageUrl: "https://omega.dohappit.com/" + product.image,
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
                      height: ScreenUtil().setHeight(60.0),
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
                          minFontSize: 14,
                          textScaleFactor: 1.5,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.greenDark,
                            decoration: TextDecoration.none,
                            fontSize: ScreenUtil().setSp(14.5),
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
                      height: ScreenUtil().setHeight(55.0),
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 8.0,
                          top: 8.0,
                        ),
                        child: AutoSizeText(
                          _formatCurrency(product.price.toInt()),
                          maxLines: 2,
                          maxFontSize: 15,
                          minFontSize: 14,
                          textScaleFactor: 1.0,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.greenDark,
                            decoration: TextDecoration.none,
                            fontSize: ScreenUtil().setSp(14.5),
                            letterSpacing: 1.0,
                            wordSpacing: 1.0,
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
            print(pd.name);
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
          height: (MediaQuery.of(context).size.height / 6.5) + 127.0,
          width: ScreenUtil().setWidth(50),
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
        height: ScreenUtil().setHeight(80),
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
                  userProfile == 2
                      ? Text(
                          "Solde Globale",
                          style: regularLightTextStyle(
                            AppColors.greenDark,
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: ScreenUtil().setHeight(16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hideBalance
                            ? "••••••"
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
            ? userSubscription == 2 && paymentIsOn == 1
                ? Padding(
                    padding: EdgeInsets.only(left: 15.0),
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
                      child: Stack(
                        overflow: Overflow.visible,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.person_outline_sharp,
                              size: 26.0,
                            ),
                          ),
                          userProfile == 3
                              ? Positioned(
                                  bottom: 15,
                                  right: -10,
                                  child: Container(
                                    height: ScreenUtil().setHeight(20),
                                    width: ScreenUtil().setWidth(20),
                                    child: Icon(
                                      Icons.info_rounded,
                                      size: 20.0,
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  )
                : Padding(
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
                            height: ScreenUtil().setHeight(20),
                            width: ScreenUtil().setWidth(20),
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
                                  height: ScreenUtil().setHeight(1),
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
                  offlineTooLong
                      ? Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ), //this right here
                          child: Container(
                            height: ScreenUtil().setHeight(200),
                            width: ScreenUtil().setWidth(320),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                    height: ScreenUtil().setHeight(16),
                                  ),
                                  Center(
                                    child: Text(
                                      "Une connexion à internet est requise pour la synchronisation des données!",
                                      style: TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: ScreenUtil().setSp(16.0),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : userSubscription == 0
                          ? Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ), //this right here
                              child: Container(
                                height: ScreenUtil().setHeight(350),
                                width: ScreenUtil().setWidth(320),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        height: ScreenUtil().setHeight(16),
                                      ),
                                      Center(
                                        child: Text(
                                          "Votre abonnement a expiré, veuillez procéder au paiement des 5.000 FCFA!",
                                          style: TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: ScreenUtil().setSp(16.0),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                              Radius.circular(
                                                                  24),
                                                          topLeft:
                                                              Radius.circular(
                                                                  24),
                                                        ),
                                                      ),
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      height: ScreenUtil()
                                                          .setHeight(250),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
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
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize:
                                                                      ScreenUtil()
                                                                          .setSp(
                                                                              14.0),
                                                                  color: Colors
                                                                      .black,
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
                                                                  onTap:
                                                                      () async {
                                                                    (Connectivity()
                                                                            .checkConnectivity())
                                                                        .then(
                                                                      (connectivityResult) async {
                                                                        if (connectivityResult == ConnectivityResult.mobile ||
                                                                            connectivityResult ==
                                                                                ConnectivityResult.wifi) {
                                                                          setState(
                                                                              () {
                                                                            _loading =
                                                                                true;
                                                                          });
                                                                          var paymentResult =
                                                                              await waveService.payment();

                                                                          if (paymentResult ==
                                                                              true) {
                                                                            // HomePage.of(context).setAppState();
                                                                            setState(() {
                                                                              _loading = false;
                                                                            });
                                                                            launch(waveLaunchUrl,
                                                                                forceSafariVC: false);

                                                                            setState(() {
                                                                              _paymentLoading = true;
                                                                            });
                                                                            Timer.periodic(Duration(seconds: 5),
                                                                                (timer) async {
                                                                              print('Runs every Five seconds');
                                                                              print("object");
                                                                              setState(() {
                                                                                _timer++;
                                                                              });
                                                                              SharedPreferences _prefs = await SharedPreferences.getInstance();
                                                                              var code = _prefs.getString('code');
                                                                              AuthService authService = AuthService();

                                                                              final user = await authService.login(
                                                                                userPhone,
                                                                                code,
                                                                              );

                                                                              if (user.suscription == 1) {
                                                                                setState(() {
                                                                                  _paymentLoading = false;
                                                                                });
                                                                                timer.cancel();
                                                                                print('Runs CANCELLED');
                                                                                print(DateTime.now());
                                                                                Navigator.of(context).pushReplacement(
                                                                                  MaterialPageRoute(
                                                                                    builder: (_) => HomePage(),
                                                                                  ),
                                                                                );
                                                                                print(DateTime.now());
                                                                              } else {
                                                                                if (_timer == 59) {
                                                                                  print("afterr");
                                                                                  timer.cancel();

                                                                                  setState(() {
                                                                                    _paymentLoading = false;
                                                                                    _timer = 0;
                                                                                  });
                                                                                }
                                                                              }
                                                                            });
                                                                          } else {
                                                                            print("Un problème est survenu!");
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
                                                                                    height: ScreenUtil().setHeight(240),
                                                                                    width: ScreenUtil().setWidth(320),
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
                                                                                              size: 40,
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: ScreenUtil().setHeight(16),
                                                                                          ),
                                                                                          Text(
                                                                                            "Assurez-vous d'avoir saisi un numéro valable et ayant assez de fonds!",
                                                                                            style: TextStyle(
                                                                                              fontFamily: "Roboto",
                                                                                              fontSize: ScreenUtil().setSp(16.0),
                                                                                              fontWeight: FontWeight.w600,
                                                                                              color: Colors.black,
                                                                                            ),
                                                                                            textAlign: TextAlign.center,
                                                                                          ),
                                                                                          Align(
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.only(
                                                                                                top: 26.0,
                                                                                              ),
                                                                                              child: FlatButton(
                                                                                                onPressed: () async {
                                                                                                  Navigator.of(context).pop();
                                                                                                },
                                                                                                child: Container(
                                                                                                  padding: EdgeInsets.all(10.0),
                                                                                                  height: ScreenUtil().setHeight(40.5),
                                                                                                  width: ScreenUtil().setWidth(120),
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                                                    color: Colors.red.shade50,
                                                                                                  ),
                                                                                                  child: Center(
                                                                                                    child: Text(
                                                                                                      "OK",
                                                                                                      style: TextStyle(
                                                                                                        fontSize: ScreenUtil().setSp(14.0),
                                                                                                        color: Colors.red,
                                                                                                        fontWeight: FontWeight.w600,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                            );
                                                                          }
                                                                        } else {
                                                                          print(
                                                                              "Un problème est survenu!");
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return Dialog(
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(20.0),
                                                                                ), //this right here
                                                                                child: Container(
                                                                                  height: ScreenUtil().setHeight(200),
                                                                                  width: ScreenUtil().setWidth(320),
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
                                                                                            size: 40,
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          height: ScreenUtil().setHeight(16),
                                                                                        ),
                                                                                        Center(
                                                                                          child: Text(
                                                                                            'Vous êtes pas connecté à internet !',
                                                                                            style: TextStyle(
                                                                                              fontFamily: "Roboto",
                                                                                              fontSize: ScreenUtil().setSp(16.0),
                                                                                              fontWeight: FontWeight.w600,
                                                                                              color: Colors.black,
                                                                                            ),
                                                                                            textAlign: TextAlign.center,
                                                                                          ),
                                                                                        ),
                                                                                        Align(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.only(
                                                                                              top: 26.0,
                                                                                            ),
                                                                                            child: FlatButton(
                                                                                              onPressed: () async {
                                                                                                Navigator.of(context).pop();
                                                                                              },
                                                                                              child: Container(
                                                                                                padding: EdgeInsets.all(10.0),
                                                                                                height: ScreenUtil().setHeight(40.5),
                                                                                                width: ScreenUtil().setWidth(120),
                                                                                                decoration: BoxDecoration(
                                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                                  color: Colors.red.shade50,
                                                                                                ),
                                                                                                child: Center(
                                                                                                  child: Text(
                                                                                                    "OK",
                                                                                                    style: TextStyle(
                                                                                                      fontSize: ScreenUtil().setSp(14.0),
                                                                                                      color: Colors.red,
                                                                                                      fontWeight: FontWeight.w600,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
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
                                                                    );
                                                                  },
                                                                  child:
                                                                      Material(
                                                                    elevation:
                                                                        5,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .all(
                                                                      Radius.circular(
                                                                          50),
                                                                    ),
                                                                    child:
                                                                        Container(
                                                                      height: ScreenUtil()
                                                                          .setHeight(
                                                                              85),
                                                                      width: ScreenUtil()
                                                                          .setWidth(
                                                                              85),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.all(
                                                                          Radius.circular(
                                                                              50),
                                                                        ),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                AppColors.greenDark.withOpacity(0.1),
                                                                            blurRadius:
                                                                                4.0,
                                                                            spreadRadius:
                                                                                0.0,
                                                                            offset:
                                                                                Offset(0.0, 0.0),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(5.0),
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
                                                height: ScreenUtil()
                                                    .setHeight(40.5),
                                                width:
                                                    ScreenUtil().setWidth(180),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    5.0,
                                                  ),
                                                  color: Colors.red
                                                      .withOpacity(.3),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Payer maintenant",
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(14.0),
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
                            )
                          : Column(
                              children: <Widget>[
                                _balanceWidget(context),
                                Expanded(
                                  child: userProfile == 3
                                      ? _productList(
                                          _searching
                                              ? searchingProducts
                                              : products,
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
                                      fontSize: ScreenUtil().setSp(16.0),
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            "$cartProductCount élements dans le panier",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.greenDark,
                                          fontSize: ScreenUtil().setSp(12.0),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                                                height:
                                                    ScreenUtil().setHeight(250),
                                                width:
                                                    ScreenUtil().setWidth(320),
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
                                                        height: ScreenUtil()
                                                            .setHeight(16),
                                                      ),
                                                      Text(
                                                        "Une erreur s'est produite, veuillez réessayer !",
                                                        style: TextStyle(
                                                          fontFamily: "Roboto",
                                                          fontSize: ScreenUtil()
                                                              .setSp(16.0),
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
                                                                height: ScreenUtil()
                                                                    .setHeight(
                                                                        40.5),
                                                                width: ScreenUtil()
                                                                    .setWidth(
                                                                        110),
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

  Padding _search(BuildContext context, List<Product> products) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 16.0,
        left: 16.0,
        bottom: 16,
      ),
      child: Container(
        height: ScreenUtil().setHeight(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
          ),
          child: Theme(
            data: ThemeData(hintColor: Colors.transparent),
            child: TextFormField(
              controller: _searchController,
              onChanged: (value) {
                print(value);
                setState(() {
                  _searching = true;
                  searchingProducts = products
                      .where(
                        (Product order) => order.name
                            .toLowerCase()
                            .contains(value.toLowerCase()),
                      )
                      .toList();
                });
              },
              onFieldSubmitted: (value) => {},
              style: TextStyle(
                color: Colors.black,
                fontSize: ScreenUtil().setSp(13.0),
                fontFamily: "Roboto",
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(bottom: 8.0),
                border: InputBorder.none,
                icon: Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 22.0,
                ),
                suffix: Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 5),
                  child: IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searching = false;
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey,
                      size: 17.0,
                    ),
                  ),
                ),
                hintText: "Rechercher avec le numéro",
                hintStyle: TextStyle(
                  fontSize: ScreenUtil().setSp(12.0),

                  // color: gray.withOpacity(0.5),
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _userList(List<User> users, context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        SizedBox(
          height: ScreenUtil().setHeight(15),
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
                  height: ScreenUtil().setHeight(200),
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
                            fontSize: ScreenUtil().setSp(16.0),

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
        height: ScreenUtil().setHeight(50),
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
                    fontSize: ScreenUtil().setSp(14.0),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  user.phone,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(14.0),
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
                    fontSize: ScreenUtil().setSp(14.0),
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
      if (orders != null && orders.length > 500) {
        setState(() {
          offlineTooLong = true;
        });
        Timer.periodic(Duration(seconds: 1), (timer) async {
          print("periodic periodic");
          (Connectivity().checkConnectivity()).then(
            (connectivityResult) {
              if (connectivityResult == ConnectivityResult.mobile ||
                  connectivityResult == ConnectivityResult.wifi) {
                setState(() {
                  setBalance();
                });
                timer.cancel();
              }
            },
          );
        });
      }
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
