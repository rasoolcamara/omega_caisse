// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/constants/app_text.dart';
import 'package:ordering_services/pages/auth/new_password_confim.dart';
import 'package:ordering_services/utils/next_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:url_launcher/url_launcher.dart';

class NewPasswordPage extends StatefulWidget {
  NewPasswordPage({
    Key key,
    this.phone,
  }) : super(key: key);

  final String phone;
  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final GlobalKey<FormState> _paymentFormKey = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController(text: "");

  final List<String> errors = [];
  String _countryCode = "+221";
  String otpCode;
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
          "Modifier mon mot de passe",
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
                                  "Définir un mot de passe",
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
                                      obscuringCharacter: '•',
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
                                        activeColor: AppColors.greenDark
                                            .withOpacity(0.3),
                                        inactiveFillColor: Colors.white,
                                        inactiveColor: AppColors.greenDark
                                            .withOpacity(0.3),
                                        selectedFillColor: Colors.white,
                                        selectedColor: AppColors.greenDark,
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

                                        nextScreen(
                                          context,
                                          NewPasswordConfirmPage(
                                            newPassword: otpCode,
                                          ),
                                        );
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
