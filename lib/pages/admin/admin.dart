// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/pages/admin/payment.dart';
import 'package:ordering_services/pages/auth/password_update.dart';
import 'package:ordering_services/pages/history/history.dart';
import 'package:ordering_services/utils/next_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/pages/auth/login.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // final UserService userService = UserService();

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
          "Panneau",
          style: TextStyle(
            fontFamily: "Roboto",
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
        elevation: 0.0,
      ),
      body: _loading
          ? spinkit
          : ListView(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                        right: 10.0,
                        top: 10.0,
                        bottom: 10.0,
                      ),
                      // height: _height,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 90,
                            width: 350,
                            decoration: BoxDecoration(
                              // image: DecorationImage(
                              //   image: AssetImage('assets/images/home.png'),
                              //   fit: BoxFit.cover,
                              // ),
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            padding: const EdgeInsets.all(0.0),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 0.0),
                              child: ListTile(
                                leading: Container(
                                  height: 55,
                                  width: 55,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: AppColors.greenDark,
                                  ),
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Text(
                                    userName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                subtitle: Text(
                                  userAddress + "  -  " + userPhone,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Divider(
                            height: 0.5,
                            color: Colors.grey,
                          ),
                          // Historique
                          userProfile == 3
                              ? InkWell(
                                  onTap: () {
                                    print("Contacter un de nos agents");
                                    nextScreen(
                                      context,
                                      HistoryPage(),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 40,
                                      right: 5.0,
                                      left: 10.0,
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(30.0),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.history,
                                          color: AppColors.greenDark,
                                          size: 25,
                                        ),
                                      ),
                                      title: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                          "Historique",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        color: Colors.black.withOpacity(.8),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          // Paiement
                          userProfile == 3 && userSubscription != 1
                              ? InkWell(
                                  onTap: () {
                                    print("Paiement");
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(24),
                                              topLeft: Radius.circular(24),
                                            ),
                                          ),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 250,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 40,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 40,
                                                    bottom: 20.0,
                                                  ),
                                                  child: Text(
                                                    "Payer votre abonnement de 5.000 FCFA avec :",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();

                                                        Navigator.of(context)
                                                            .push(
                                                          PageRouteBuilder(
                                                            pageBuilder:
                                                                (_, __, ___) =>
                                                                    PaymentPage(
                                                              wallet: 1,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Material(
                                                        elevation: 5,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(50),
                                                        ),
                                                        child: Container(
                                                          height: 85,
                                                          width: 85,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
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
                                                                    .withOpacity(
                                                                        0.1),
                                                                blurRadius: 4.0,
                                                                spreadRadius:
                                                                    0.0,
                                                                offset: Offset(
                                                                    0.0, 0.0),
                                                              )
                                                            ],
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            child: Image(
                                                              image: AssetImage(
                                                                "assets/logo-part/orange-money.png",
                                                              ),
                                                              fit: BoxFit.cover,
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
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.of(context)
                                                            .push(
                                                          PageRouteBuilder(
                                                            pageBuilder:
                                                                (_, __, ___) =>
                                                                    PaymentPage(
                                                              wallet: 2,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Material(
                                                        elevation: 5,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(50),
                                                        ),
                                                        child: Container(
                                                          height: 85,
                                                          width: 85,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
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
                                                                    .withOpacity(
                                                                        0.1),
                                                                blurRadius: 4.0,
                                                                spreadRadius:
                                                                    0.0,
                                                                offset: Offset(
                                                                    0.0, 0.0),
                                                              )
                                                            ],
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            child: Image(
                                                              image: AssetImage(
                                                                "assets/logo-part/wave.png",
                                                              ),
                                                              fit: BoxFit.cover,
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 16,
                                      right: 5.0,
                                      left: 10.0,
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(30.0),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.paid,
                                          color: AppColors.greenDark,
                                          size: 30,
                                        ),
                                      ),
                                      title: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                          "Paiement",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          "Veullez payer votre abonnement!",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 11,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        color: Colors.black.withOpacity(.8),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          // Modifier mot de passe
                          InkWell(
                            onTap: () {
                              nextScreen(
                                context,
                                PasswordUpdatePage(),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                right: 5.0,
                                left: 10.0,
                              ),
                              child: ListTile(
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.password,
                                    color: AppColors.greenDark,
                                    size: 25,
                                  ),
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    "Modifier mon mot de passe",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: Colors.black.withOpacity(.8),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          // Contacter un de nos agents
                          InkWell(
                            onTap: () {
                              print("Contacter un de nos agents");
                              launch("tel://+221786342370");
                              // _callSAV();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                right: 5.0,
                                left: 10.0,
                              ),
                              child: ListTile(
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.phone,
                                    color: AppColors.greenDark,
                                    size: 25,
                                  ),
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    "Contacter un de nos agents",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: Colors.black.withOpacity(.8),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          // Se déconnecter
                          InkWell(
                            onTap: () {
                              print("Se déconnecter");
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
                                              'Êtes-vous sûr de vouloir vous déconnecter',
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
                                                      SharedPreferences _prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      await _prefs.setString(
                                                          "activeToken", '');
                                                      await _prefs.setBool(
                                                          "isLoggedIn", false);
                                                      await _prefs.setInt(
                                                          "userId", 0);
                                                      await _prefs.setInt(
                                                          "profileId", 0);

                                                      await _prefs.setInt(
                                                          "userSubscription",
                                                          2);
                                                      await _prefs.setString(
                                                          "userPhone", '');
                                                      await _prefs.setString(
                                                          "userName", '');
                                                      await _prefs.setString(
                                                          "userAddress", '');
                                                      await _prefs.setInt(
                                                          "categoryId", 0);
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pushReplacement(
                                                        PageRouteBuilder(
                                                          pageBuilder:
                                                              (_, __, ___) =>
                                                                  LoginPage(),
                                                        ),
                                                      );
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
                                                          "Déconnexion",
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
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                right: 5.0,
                                left: 10.0,
                              ),
                              child: ListTile(
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.logout_outlined,
                                    color: Colors.red,
                                    size: 25,
                                  ),
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    "Se déconnecter",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: Colors.black.withOpacity(.8),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  void _callSAV() async {
    if (!await launch("tel://+221786342370")) throw 'Could not launch tel';
  }
}
