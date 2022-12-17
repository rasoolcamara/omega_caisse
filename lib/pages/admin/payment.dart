// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/pages/home/home.dart';
import 'package:ordering_services/services/auth/auth_service.dart';
import 'package:ordering_services/services/checkout_invoice.dart';
import 'package:ordering_services/services/softPay/orange_money_senegal.dart';
import 'package:ordering_services/services/softPay/wave.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage({
    Key key,
    this.wallet,
  }) : super(key: key);

  final int wallet;
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final GlobalKey<FormState> _paymentFormKey = GlobalKey<FormState>();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _codeController = TextEditingController();

  final PaydunyaService paydunyaService = PaydunyaService();
  final WaveService waveService = WaveService();
  final OMSNService omsnService = OMSNService();

  final List<String> errors = [];
  String _countryCode = "+221";

  bool _loading = false;

  bool _paymentLoading = false;

  bool payed = false;

  int _timer = 1;

  final spinkit = SpinKitRing(
    color: AppColors.greenDark.withOpacity(0.5),
    lineWidth: 8.0,
    size: 90.0,
  );

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: userPhone);
  }

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
          widget.wallet == 1 ? "Paiement Orange Money" : "Paiement Wave",
          style: TextStyle(
            fontFamily: "Roboto",
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
        elevation: 0.0,
      ),
      body: _loading
          ? spinkit
          : _paymentLoading
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
                        'Votre paiement est en cours de traitement. Merci de valider le paiement après reception de sms pour le compléter.',
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                )
              : ListView(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(bottom: 50.0),
                          // height: _height,
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.white),
                          child: Form(
                            key: _paymentFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Phone
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 25.0,
                                    right: 25.0,
                                    top: 60.0,
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
                                                hintColor: Colors.transparent),
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
                                // Amount
                                /* Padding(
                              padding: const EdgeInsets.only(
                                left: 25.0,
                                right: 25.0,
                                top: 25.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Montant",
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
                                            hintColor: Colors.transparent),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 0.0,
                                          ),
                                          child: TextFormField(
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.start,
                                            keyboardType: TextInputType.phone,
                                            autocorrect: false,
                                            autofocus: false,
                                            controller: _amountController,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                left: 20.0,
                                                bottom: 16,
                                              ),
                                              filled: true,
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.never,
                                              fillColor: Colors.transparent,
                                              labelText: '',
                                              hintStyle: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                              labelStyle: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                              // suffix
                                              suffixIcon: Material(
                                                elevation: 0,
                                                color: Colors.transparent,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(30),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    15.0,
                                                  ),
                                                  child: Text(
                                                    'FCFA',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ), */

                                widget.wallet == 1
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 25.0, right: 25.0, top: 25.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "Code OTP",
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
                                                padding:
                                                    const EdgeInsets.all(0.0),
                                                child: Theme(
                                                  data: ThemeData(
                                                      hintColor:
                                                          Colors.transparent),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 0.0,
                                                    ),
                                                    child: TextFormField(
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                      keyboardType:
                                                          TextInputType.phone,
                                                      autocorrect: false,
                                                      autofocus: false,
                                                      controller:
                                                          _codeController,
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                          left: 20.0,
                                                          bottom: 16,
                                                        ),
                                                        filled: true,
                                                        floatingLabelBehavior:
                                                            FloatingLabelBehavior
                                                                .never,
                                                        fillColor:
                                                            Colors.transparent,
                                                        labelText: '',
                                                        hintStyle: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                        labelStyle: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8.0,
                                            ),
                                            Text(
                                              "Tapez #144#391*code_secret# pour obtenir un code de paiement!",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),

                                // FormError(errors: errors),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12.0,
                                    right: 12.0,
                                    top: 65.0,
                                  ),
                                  child: FlatButton(
                                    onPressed: () async {
                                      (Connectivity().checkConnectivity()).then(
                                        (connectivityResult) async {
                                          if (connectivityResult ==
                                                  ConnectivityResult.mobile ||
                                              connectivityResult ==
                                                  ConnectivityResult.wifi) {
                                            if (_phoneController
                                                .text.isNotEmpty) {
                                              setState(() {
                                                _loading = true;
                                              });
                                              var paymentResult = false;

                                              switch (widget.wallet) {
                                                case 2:
                                                  paymentResult =
                                                      await waveService
                                                          .payment();
                                                  break;

                                                default:
                                              }

                                              if (paymentResult == true) {
                                                // HomePage.of(context).setAppState();
                                                setState(() {
                                                  _loading = false;
                                                });
                                                launch(waveLaunchUrl,
                                                    forceSafariVC: false);

                                                if (widget.wallet == 2) {
                                                  setState(() {
                                                    _paymentLoading = true;
                                                  });
                                                  Timer.periodic(
                                                      Duration(seconds: 5),
                                                      (timer) async {
                                                    print(
                                                        'Runs every Five seconds');
                                                    print("object");
                                                    setState(() {
                                                      _timer++;
                                                    });
                                                    SharedPreferences _prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    var code = _prefs
                                                        .getString('code');
                                                    AuthService authService =
                                                        AuthService();

                                                    final user =
                                                        await authService.login(
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
                                                      Navigator.of(context)
                                                          .pushReplacement(
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              HomePage(),
                                                        ),
                                                      );
                                                      print(DateTime.now());
                                                    } else {
                                                      if (_timer == 59) {
                                                        print("afterr");
                                                        timer.cancel();

                                                        setState(() {
                                                          _paymentLoading =
                                                              false;
                                                          _timer = 0;
                                                        });
                                                      }
                                                    }
                                                  });
                                                  // showDialog(
                                                  //   context: context,
                                                  //   builder:
                                                  //       (BuildContext context) {
                                                  //     return Dialog(
                                                  //       shape:
                                                  //           RoundedRectangleBorder(
                                                  //         borderRadius:
                                                  //             BorderRadius.circular(
                                                  //                 20.0),
                                                  //       ), //this right here
                                                  //       child: Container(
                                                  //         height: 290,
                                                  //         width: 320,
                                                  //         child: Padding(
                                                  //           padding:
                                                  //               const EdgeInsets
                                                  //                   .all(12.0),
                                                  //           child: Column(
                                                  //             mainAxisAlignment:
                                                  //                 MainAxisAlignment
                                                  //                     .center,
                                                  //             crossAxisAlignment:
                                                  //                 CrossAxisAlignment
                                                  //                     .start,
                                                  //             children: [
                                                  //               Align(
                                                  //                 child: Container(
                                                  //                   height: 90,
                                                  //                   width: 90,
                                                  //                   decoration:
                                                  //                       BoxDecoration(
                                                  //                     borderRadius:
                                                  //                         BorderRadius
                                                  //                             .all(
                                                  //                       Radius.circular(
                                                  //                           10.0),
                                                  //                     ),
                                                  //                     image:
                                                  //                         DecorationImage(
                                                  //                       image:
                                                  //                           AssetImage(
                                                  //                         'assets/success.png',
                                                  //                       ),
                                                  //                     ),
                                                  //                   ),
                                                  //                 ),
                                                  //               ),
                                                  //               SizedBox(
                                                  //                 height: 24,
                                                  //               ),
                                                  //               Text(
                                                  //                 'Votre paiement a été initié, veuillez finaliser sur votre téléphone!',
                                                  //                 style: TextStyle(
                                                  //                   fontFamily:
                                                  //                       "Roboto",
                                                  //                   fontSize: 16.0,
                                                  //                   fontWeight:
                                                  //                       FontWeight
                                                  //                           .w500,
                                                  //                   color: Colors
                                                  //                       .black,
                                                  //                 ),
                                                  //                 textAlign:
                                                  //                     TextAlign
                                                  //                         .center,
                                                  //               ),
                                                  //               Align(
                                                  //                 child: Padding(
                                                  //                   padding:
                                                  //                       const EdgeInsets
                                                  //                           .only(
                                                  //                     top: 26.0,
                                                  //                   ),
                                                  //                   child:
                                                  //                       FlatButton(
                                                  //                     onPressed:
                                                  //                         () async {
                                                  //                       if (widget
                                                  //                               .wallet ==
                                                  //                           2) {
                                                  //                         Navigator.of(
                                                  //                                 context)
                                                  //                             .pop();
                                                  //                         Timer.periodic(
                                                  //                             Duration(
                                                  //                                 seconds: 5),
                                                  //                             (timer) async {
                                                  //                           print(
                                                  //                               'Runs every Five seconds');
                                                  //                           print(
                                                  //                               "object");
                                                  //                           setState(
                                                  //                               () {
                                                  //                             _timer++;
                                                  //                           });
                                                  //                           SharedPreferences
                                                  //                               _prefs =
                                                  //                               await SharedPreferences.getInstance();
                                                  //                           var code =
                                                  //                               _prefs.getString('code');
                                                  //                           AuthService
                                                  //                               authService =
                                                  //                               AuthService();

                                                  //                           final user =
                                                  //                               await authService.login(
                                                  //                             userPhone,
                                                  //                             code,
                                                  //                           );

                                                  //                           if (user.suscription ==
                                                  //                               1) {
                                                  //                             setState(
                                                  //                                 () {
                                                  //                               _loading =
                                                  //                                   false;
                                                  //                             });
                                                  //                             timer
                                                  //                                 .cancel();
                                                  //                             print(
                                                  //                                 'Runs CANCELLED');
                                                  //                             print(
                                                  //                                 DateTime.now());
                                                  //                             Navigator.of(context)
                                                  //                                 .pushReplacement(
                                                  //                               MaterialPageRoute(
                                                  //                                 builder: (_) => HomePage(),
                                                  //                               ),
                                                  //                             );
                                                  //                             print(
                                                  //                                 DateTime.now());
                                                  //                           } else {
                                                  //                             if (_timer ==
                                                  //                                 59) {
                                                  //                               print("afterr");
                                                  //                               timer.cancel();

                                                  //                               setState(() {
                                                  //                                 _loading = false;
                                                  //                                 _timer = 0;
                                                  //                               });
                                                  //                             }
                                                  //                           }
                                                  //                         });
                                                  //                       } else {
                                                  //                         Navigator.of(
                                                  //                                 context)
                                                  //                             .pop();
                                                  //                         Navigator.of(
                                                  //                                 context)
                                                  //                             .pushReplacement(
                                                  //                           MaterialPageRoute(
                                                  //                             builder: (_) =>
                                                  //                                 HomePage(),
                                                  //                           ),
                                                  //                         );
                                                  //                       }
                                                  //                     },
                                                  //                     child:
                                                  //                         Container(
                                                  //                       padding:
                                                  //                           EdgeInsets.all(
                                                  //                               10.0),
                                                  //                       height:
                                                  //                           40.5,
                                                  //                       width: 120,
                                                  //                       decoration:
                                                  //                           BoxDecoration(
                                                  //                         borderRadius:
                                                  //                             BorderRadius.circular(
                                                  //                                 5.0),
                                                  //                         color: Colors
                                                  //                             .green
                                                  //                             .shade50,
                                                  //                       ),
                                                  //                       child:
                                                  //                           Center(
                                                  //                         child:
                                                  //                             Text(
                                                  //                           "OK",
                                                  //                           style:
                                                  //                               TextStyle(
                                                  //                             fontSize:
                                                  //                                 14.0,
                                                  //                             color: Colors
                                                  //                                 .green
                                                  //                                 .shade400,
                                                  //                             fontWeight:
                                                  //                                 FontWeight.w600,
                                                  //                           ),
                                                  //                         ),
                                                  //                       ),
                                                  //                     ),
                                                  //                   ),
                                                  //                 ),
                                                  //               ),
                                                  //             ],
                                                  //           ),
                                                  //         ),
                                                  //       ),
                                                  //     );
                                                  //   },
                                                  // );
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
                                                                  .circular(
                                                                      20.0),
                                                        ), //this right here
                                                        child: Container(
                                                          height: 290,
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
                                                                  child:
                                                                      Container(
                                                                    height: 90,
                                                                    width: 90,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            10.0),
                                                                      ),
                                                                      image:
                                                                          DecorationImage(
                                                                        image:
                                                                            AssetImage(
                                                                          'assets/success.png',
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 24,
                                                                ),
                                                                Text(
                                                                  'Votre paiement a été éffectuée avec succès!',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        "Roboto",
                                                                    fontSize:
                                                                        16.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                Align(
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .only(
                                                                      top: 26.0,
                                                                    ),
                                                                    child:
                                                                        FlatButton(
                                                                      onPressed:
                                                                          () async {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        Navigator.of(context)
                                                                            .pushReplacement(
                                                                          MaterialPageRoute(
                                                                            builder: (_) =>
                                                                                HomePage(),
                                                                          ),
                                                                        );
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            EdgeInsets.all(10.0),
                                                                        height:
                                                                            40.5,
                                                                        width:
                                                                            120,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5.0),
                                                                          color: Colors
                                                                              .green
                                                                              .shade50,
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            "OK",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 14.0,
                                                                              color: Colors.green.shade400,
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
                                                setState(() {
                                                  _loading = false;
                                                });
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
                                                        height: 240,
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
                                                                "Assurez-vous d'avoir saisi un numéro valable et ayant assez de fonds!",
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
                                                                            .shade50,
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
                                            } else {
                                              print("Un problème est survenu!");
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
                                                      height: 200,
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
                                                            Text(
                                                              'Saisissez un numéro de téléphone valable et le montant !',
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
                                                                          .shade50,
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
                                          } else {
                                            print("Un problème est survenu!");
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
                                                    height: 200,
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
                                                              'Vous êtes pas connecté à internet !',
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
                                                                        .shade50,
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
                                            "Valider",
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
    _amountController.dispose();
    super.dispose();
  }
}
