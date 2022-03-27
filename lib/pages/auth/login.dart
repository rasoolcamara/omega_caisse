// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/pages/auth/new_password_confim.dart';
import 'package:ordering_services/pages/home/home.dart';
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
                    'Configuration en cours ...',
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
                            height: 90,
                            width: 90,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: AppColors.greenLigth,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 35,
                              color: AppColors.greenDark,
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
                                                    TextInputType.phone,
                                                autocorrect: false,
                                                autofocus: false,
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
                                                  labelText: '',
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
                                                    color: Colors.black,
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
                                    top: 50.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Code secret",
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
                                            obscureText: false,
                                            autoFocus: true,
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
                                              // setState(() {
                                              //   otpCode = value;
                                              // });

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
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12.0,
                                    right: 12.0,
                                    top: 70.0,
                                  ),
                                  child: FlatButton(
                                    onPressed: () async {
                                      Navigator.of(context).pushReplacement(
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              HomePage(),
                                        ),
                                      );
                                      /* if (application != null) {
                                        print("Athentification Réussi!");
                                        print(application.toString());

                                        // setState(() {
                                        //   _loading = false;
                                        // });
                                      } else {
                                        
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ), //this right here
                                              child: Container(
                                                height: 200,
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
                                                          color: red,
                                                          size: 40,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 16,
                                                      ),
                                                      Text(
                                                        'Veuillez vérifier les données saisies!',
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
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          10.0),
                                                              height: 40.5,
                                                              width: 120,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0),
                                                                color: red10,
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  "OK",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14.0,
                                                                    color: red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
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
                                      } */
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
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}











/* import 'package:flutter/material.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/constants/app_text.dart';
import 'package:ordering_services/pages/home.dart';
import 'package:ordering_services/pages/home/home.dart';
import 'package:ordering_services/utils/next_screen.dart';

import '../ordering_page.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    //topLeft: Radius.circular(60),
                    // topRight: Radius.circular(60),
                    //bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(300),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://cdn.pixabay.com/photo/2015/03/30/12/37/jellyfish-698521__340.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 30,
                      width: 80,
                      height: 200,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://cdn.pixabay.com/photo/2019/12/24/08/54/flying-dandelions-4716287__340.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://cdn.pixabay.com/photo/2016/08/25/07/30/red-1618916__340.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      width: 80,
                      height: 150,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://cdn.pixabay.com/photo/2019/10/22/07/52/dandelions-4567966__340.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      child: Container(
                        margin: EdgeInsets.only(top: 50),
                        child: Center(
                          child: Text(
                            "Ordering Services",
                            style: bigLightTextStyle(Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(143, 148, 251, .2),
                            blurRadius: 20.0,
                            offset: Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[100]),
                              ),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Téléphone",
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                          OTPFields(),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Mot de passe",
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        nextScreen(
                          context,
                          HomePage(),
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [
                              AppColors.PRIMARY_COLOR,
                              AppColors.ACCENT_COLOR,
                            ])),
                        child: Center(
                          child: Text(
                            "Connexion",
                            style: regularBoldTextStyle(Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 70,
                    ),
                    Text(
                      "Mot de passe oublié?",
                      style: regularLightTextStyle(AppColors.PRIMARY_COLOR),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

final inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(8.0),
  borderSide: BorderSide(color: Colors.grey.shade400),
);

final inputDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 16.0),
  border: inputBorder,
  focusedBorder: inputBorder,
  enabledBorder: inputBorder,
);

class OTPFields extends StatefulWidget {
  const OTPFields({
    Key key,
  }) : super(key: key);

  @override
  _OTPFieldsState createState() => _OTPFieldsState();
}

class _OTPFieldsState extends State<OTPFields> {
  FocusNode pin2FN;
  FocusNode pin3FN;
  FocusNode pin4FN;
  final pinStyle = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    pin2FN = FocusNode();
    pin3FN = FocusNode();
    pin4FN = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    pin2FN?.dispose();
    pin3FN?.dispose();
    pin4FN?.dispose();
  }

  void nextField(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 60,
                child: TextFormField(
                  autofocus: true,
                  style: pinStyle,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: inputDecoration,
                  onChanged: (value) {
                    nextField(value, pin2FN);
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: TextFormField(
                  focusNode: pin2FN,
                  style: pinStyle,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: inputDecoration,
                  onChanged: (value) => nextField(value, pin3FN),
                ),
              ),
              SizedBox(
                width: 60,
                child: TextFormField(
                  focusNode: pin3FN,
                  style: pinStyle,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: inputDecoration,
                  onChanged: (value) => nextField(value, pin4FN),
                ),
              ),
              SizedBox(
                width: 60,
                child: TextFormField(
                  focusNode: pin4FN,
                  style: pinStyle,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: inputDecoration,
                  onChanged: (value) {
                    if (value.length == 1) {
                      pin4FN.unfocus();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}
 */