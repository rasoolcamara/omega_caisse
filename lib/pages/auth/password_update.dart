// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/constants/app_text.dart';
import 'package:ordering_services/pages/auth/new_password.dart';
import 'package:ordering_services/services/auth/auth_service.dart';
import 'package:ordering_services/utils/next_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:url_launcher/url_launcher.dart';

class PasswordUpdatePage extends StatefulWidget {
  PasswordUpdatePage({
    Key key,
    // this.wallet,
    this.phone,
  }) : super(key: key);

  // final Wallet wallet;
  final String phone;
  @override
  _PasswordUpdatePageState createState() => _PasswordUpdatePageState();
}

class _PasswordUpdatePageState extends State<PasswordUpdatePage> {
  final GlobalKey<FormState> _paymentFormKey = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController(text: "");

  AuthService authService = AuthService();

  final List<String> errors = [];
  String _countryCode = "+221";
  String otpCode;
  bool _loading = false;
  bool _error = false;

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
          "Modifier mon code secret",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
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
                      padding: const EdgeInsets.only(bottom: 50.0),
                      // height: _height,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  height: 45,
                                ),
                                Text(
                                  "Saisissez le code secret actuel",
                                  style: TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Form(
                            key: _paymentFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // OTP Fields
                                Padding(
                                  padding: const EdgeInsets.all(28.0),
                                  child: Center(
                                    child: PinCodeTextField(
                                      backgroundColor: Colors.white,
                                      appContext: context,
                                      length: 4,
                                      obscureText: true,
                                      autoFocus: true,
                                      hintCharacter: '•',
                                      hintStyle: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      blinkWhenObscuring: false,
                                      animationType: AnimationType.fade,
                                      pinTheme: PinTheme(
                                        shape: PinCodeFieldShape.underline,
                                        borderWidth: 3.0,
                                        activeFillColor: Colors.white,
                                        activeColor: _error
                                            ? Colors.red.withOpacity(0.6)
                                            : AppColors.greenDark
                                                .withOpacity(0.3),
                                        inactiveFillColor: Colors.white,
                                        inactiveColor: _error
                                            ? Colors.red.withOpacity(0.6)
                                            : AppColors.greenDark
                                                .withOpacity(0.3),
                                        selectedFillColor: Colors.white,
                                        selectedColor: _error
                                            ? Colors.red
                                            : AppColors.greenDark,
                                      ),
                                      cursorColor: Colors.black26,
                                      animationDuration:
                                          Duration(milliseconds: 300),

                                      // controller: textEditingController,
                                      keyboardType: TextInputType.number,

                                      onCompleted: (value) async {
                                        print("Completed");
                                        setState(() {
                                          otpCode = value;
                                        });

                                        final result = await authService
                                            .verifyOTPCode(otpCode);

                                        if (result) {
                                          nextScreen(
                                            context,
                                            NewPasswordPage(),
                                          );
                                        } else {
                                          setState(() {
                                            _error = true;
                                          });
                                        }
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

                                // FormError(errors: errors),
                                /* Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12.0,
                                    right: 12.0,
                                    top: 45.0,
                                  ),
                                  child: FlatButton(
                                    onPressed: () async {
                                      nextScreen(
                                        context,
                                        NewPasswordPage(),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Container(
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          color: AppColors.greenDark,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Suivant",
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
                                ), */
                                SizedBox(
                                  height: 35.0,
                                ),
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
    controller.dispose();
    super.dispose();
  }
}
