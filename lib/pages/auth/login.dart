// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/pages/auth/new_password_confim.dart';
import 'package:ordering_services/pages/home/home.dart';
import 'package:ordering_services/services/auth/auth_service.dart';
import 'package:ordering_services/utils/next_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final List<String> errors = [];
  String _countryCode = "+221";

  AuthService authService = AuthService();
  String otpCode;

  bool _loading = false;
  final spinkit = SpinKitRing(
    color: AppColors.greenDark.withOpacity(0.5),
    lineWidth: 10.0,
    size: 100.0,
  );

  // doro.gueye@paydunya.com
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.greenDark,
        elevation: 0.0,
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  spinkit,
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Connexion en cours ...',
                  )
                ],
              ),
            )
          : ListView(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                        bottom: 50.0,
                        top: 40.0,
                      ),
                      // height: _height,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 150,
                            width: 150,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              // color: AppColors.greenLigth,
                            ),
                            child: Image(
                              image: AssetImage(
                                'assets/ocaisse.png',
                              ),
                            ),
                          ),
                          Form(
                            key: _loginFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Email and Phone
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 25.0,
                                    right: 25.0,
                                    top: 40.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Numéro de téléphone",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Container(
                                        height: 52.5,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Theme(
                                            data: ThemeData(
                                              hintColor: Colors.transparent,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: TextFormField(
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.start,
                                                keyboardType:
                                                    TextInputType.number,
                                                textInputAction:
                                                    TextInputAction.next,
                                                autocorrect: false,
                                                autofocus: true,
                                                controller: _phoneController,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                    left: 20.0,
                                                    bottom: 16,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.transparent,
                                                  labelText:
                                                      'Numéro de téléphone',
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .never,
                                                  hintStyle: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                  // prefixIcon: CountryCodePicker(
                                                  //   textStyle: TextStyle(
                                                  //     fontSize: 15,
                                                  //     fontWeight:
                                                  //         FontWeight.w500,
                                                  //     color: Colors.black,
                                                  //   ),
                                                  //   dialogTextStyle: TextStyle(
                                                  //     fontSize: 15,
                                                  //     fontWeight:
                                                  //         FontWeight.w500,
                                                  //     color: Colors.black,
                                                  //   ),
                                                  //   flagWidth: 30,
                                                  //   hideSearch: true,
                                                  //   dialogSize: Size(320, 300),
                                                  //   initialSelection: 'SN',
                                                  //   countryFilter: [
                                                  //     'SN',
                                                  //     'CI',
                                                  //     'BJ'
                                                  //   ],
                                                  //   onChanged: (country) {
                                                  //     _countryCode =
                                                  //         country.dialCode;
                                                  //     print(country.name);
                                                  //   },
                                                  // ),
                                                  labelStyle: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black
                                                        .withOpacity(0.4),
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
                                // OTP Fields
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 25.0,
                                    right: 25.0,
                                    top: 40.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Mot de passe",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Container(
                                        height: 52.5,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Theme(
                                            data: ThemeData(
                                              hintColor: Colors.transparent,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: TextFormField(
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.start,
                                                keyboardType:
                                                    TextInputType.number,
                                                autocorrect: false,
                                                autofocus: false,
                                                obscureText: true,
                                                maxLength: 4,
                                                controller: _passwordController,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  counterText: '',
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                    left: 20.0,
                                                    bottom: 16,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.transparent,
                                                  labelText: 'Mot de passe',
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .never,
                                                  hintStyle: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                  labelStyle: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black
                                                        .withOpacity(0.4),
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
                                // bnj,
                                /* Padding(
                                  padding: const EdgeInsets.only(
                                    left: 25.0,
                                    right: 25.0,
                                    top: 50.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Mot de passe",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Center(
                                          child: PinCodeTextField(
                                            backgroundColor: Colors.white,
                                            appContext: context,
                                            length: 4,
                                            obscureText: true,
                                            autoFocus: false,
                                            obscuringCharacter: '•',
                                            hintCharacter: '•',
                                            hintStyle: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            blinkWhenObscuring: false,
                                            animationType: AnimationType.fade,
                                            pinTheme: PinTheme(
                                              shape:
                                                  PinCodeFieldShape.underline,
                                              borderWidth: 3.0,
                                              activeFillColor: Colors.white,
                                              activeColor: AppColors.greenDark
                                                  .withOpacity(0.3),
                                              inactiveFillColor: Colors.white,
                                              inactiveColor: AppColors.greenDark
                                                  .withOpacity(0.3),
                                              selectedFillColor: Colors.white,
                                              selectedColor:
                                                  AppColors.greenDark,
                                            ),
                                            cursorColor: Colors.black,
                                            animationDuration:
                                                Duration(milliseconds: 300),
                                            enableActiveFill: true,
                                            // errorAnimationController: errorController,
                                            // controller: textEditingController,
                                            keyboardType: TextInputType.number,

                                            onCompleted: (value) {
                                              print("Completed");
                                              setState(() {
                                                otpCode = value;
                                              });

                                              // nextScreen(
                                              //   context,
                                              //   NewPasswordConfirmPage(
                                              //     newPassword: otpCode,
                                              //   ),
                                              // );
                                            },
                                            // onTap: () {
                                            //   print("Pressed");
                                            // },
                                            onChanged: (value) {
                                              print(value);
                                              setState(() {
                                                // currentText = value;
                                              });
                                            },
                                            beforeTextPaste: (text) {
                                              print("Allowing to paste $text");
                                              //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                              //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                              return true;
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ), */

                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12.0,
                                    right: 12.0,
                                    top: 70.0,
                                  ),
                                  child: FlatButton(
                                    onPressed: () async {
                                      (Connectivity().checkConnectivity()).then(
                                        (connectivityResult) async {
                                          if (connectivityResult ==
                                                  ConnectivityResult.mobile ||
                                              connectivityResult ==
                                                  ConnectivityResult.wifi) {
                                            if (_phoneController.text.isEmpty ||
                                                _passwordController
                                                    .text.isEmpty) {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Dialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ), //this right here
                                                    child: Container(
                                                      height: 250,
                                                      width: 320,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12.0),
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
                                                                color:
                                                                    Colors.red,
                                                                size: 40,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 16,
                                                            ),
                                                            Center(
                                                              child: Text(
                                                                "Les champs sont obligatoires!",
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      "Roboto",
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            Align(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  top: 26.0,
                                                                ),
                                                                child:
                                                                    FlatButton(
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            10.0),
                                                                    height:
                                                                        40.5,
                                                                    width: 120,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      color: Colors
                                                                          .red
                                                                          .withOpacity(
                                                                              .2),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        "OK",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14.0,
                                                                          color:
                                                                              Colors.red,
                                                                          fontWeight:
                                                                              FontWeight.w600,
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
                                            } else {
                                              setState(() {
                                                _loading = true;
                                              });
                                              final user =
                                                  await authService.login(
                                                _phoneController.text,
                                                _passwordController.text,
                                              );
                                              setState(() {
                                                _loading = false;
                                              });
                                              if (user != null) {
                                                print(
                                                    "Athentification Réussi!");
                                                print(user.toString());
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                  PageRouteBuilder(
                                                    pageBuilder: (_, __, ___) =>
                                                        HomePage(),
                                                  ),
                                                );
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20.0),
                                                      ), //this right here
                                                      child: Container(
                                                        height: 300,
                                                        width: 320,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12.0),
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
                                                                  color: Colors
                                                                      .red,
                                                                  size: 40,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 16,
                                                              ),
                                                              Text(
                                                                'Veuillez vérifier les données saisies!',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      "Roboto",
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              Align(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                    top: 26.0,
                                                                  ),
                                                                  child:
                                                                      FlatButton(
                                                                    onPressed:
                                                                        () async {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              10.0),
                                                                      height:
                                                                          40.5,
                                                                      width:
                                                                          120,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                        color: Colors
                                                                            .red
                                                                            .withOpacity(.2),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          "OK",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14.0,
                                                                            color:
                                                                                Colors.red,
                                                                            fontWeight:
                                                                                FontWeight.w600,
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
                                            }
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ), //this right here
                                                  child: Container(
                                                    height: 250,
                                                    width: 320,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
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
                                                              size: 40,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 16,
                                                          ),
                                                          Center(
                                                            child: Text(
                                                              "La connexion à internet est obligatoire pour se connecter!",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Roboto",
                                                                fontSize: 16.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          Align(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                top: 26.0,
                                                              ),
                                                              child: FlatButton(
                                                                onPressed:
                                                                    () async {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10.0),
                                                                  height: 40.5,
                                                                  width: 120,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5.0),
                                                                    color: Colors
                                                                        .red
                                                                        .withOpacity(
                                                                            .2),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      "OK",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14.0,
                                                                        color: Colors
                                                                            .red,
                                                                        fontWeight:
                                                                            FontWeight.w600,
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Container(
                                        height: 55.5,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: AppColors.greenDark,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Connexion",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 55.0,
                                ),
                                /* InkWell(
                                  onTap: () {
                                    print("Contacter un de nos agents");
                                    launch("tel://+221786342370");
                                    // _callSAV();
                                  },
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 16,
                                        right: 5.0,
                                        left: 10.0,
                                      ),
                                      child: Text(
                                        "Mot de passe oublié ?",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: AppColors.greenDark,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ), */
                              ],
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

  void _launchURL(_url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
