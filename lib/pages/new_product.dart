// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/constants/app_text.dart';
import 'package:ordering_services/models/products.dart';
import 'package:ordering_services/pages/home/home.dart';
import 'package:ordering_services/widget/button.dart';

class NewProductPage extends StatefulWidget {
  Product product;

  NewProductPage({Key key, this.product}) : super(key: key);

  @override
  NewProductPageState createState() => NewProductPageState();
}

// Create a corresponding State class. This class holds data related to the form.
class NewProductPageState extends State<NewProductPage> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: "Produit_xxx");
    _quantityController = TextEditingController(text: "1");
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.greenDark,
        title: Text(
          "Nouveau Produit",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
            decoration: TextDecoration.none,
            fontSize: 20,
          ),
        ),
        elevation: 0.0,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                cursorColor: AppColors.greenDark,
                style: TextStyle(
                  color: AppColors.greenDark,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.account_tree_outlined,
                    color: AppColors.greenDark,
                  ),
                  focusColor: AppColors.greenDark,
                  hoverColor: AppColors.greenDark,
                  fillColor: AppColors.greenDark,
                  hintText: 'Nom du produit',
                  labelText: 'Nom',
                  hintStyle: TextStyle(
                    color: AppColors.greenDark,
                    fontSize: 13,
                  ),
                  labelStyle: TextStyle(
                    color: AppColors.greenDark,
                  ),
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _priceController,
                decoration: const InputDecoration(
                  icon: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.greenDark,
                  ),
                  hintText: 'Prix du produit',
                  labelText: 'Prix',
                  hintStyle: TextStyle(
                    color: AppColors.greenDark,
                    fontSize: 13,
                  ),
                  labelStyle: TextStyle(
                    color: AppColors.greenDark,
                  ),
                  focusColor: AppColors.greenDark,
                  hoverColor: AppColors.greenDark,
                  fillColor: AppColors.greenDark,
                ),
              ),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  icon: const Icon(
                    Icons.add_box_outlined,
                    color: AppColors.greenDark,
                  ),
                  hintText: 'Quantité',
                  labelText: 'Quantité',
                  hintStyle: TextStyle(
                    color: AppColors.greenDark,
                    fontSize: 13,
                  ),
                  labelStyle: TextStyle(
                    color: AppColors.greenDark,
                  ),
                  focusColor: AppColors.greenDark,
                  hoverColor: AppColors.greenDark,
                  fillColor: AppColors.greenDark,
                ),
              ),
              SizedBox(
                height: 64,
              ),
              Center(
                child: SizedBox(
                  width: 180,
                  child: DefaultButton(
                    text: "Sauvegarder",
                    press: () {
                      if (_nameController.text.isNotEmpty &&
                          _priceController.text.isNotEmpty &&
                          _quantityController.text.isNotEmpty) {
                        if (num.tryParse(_priceController.text) != null &&
                            int.tryParse(_quantityController.text) != null) {
                          setState(() {
                            widget.product.name = _nameController.text;
                            widget.product.price =
                                num.parse(_priceController.text);
                            widget.product.quantity =
                                int.parse(_quantityController.text);
                          });

                          Navigator.pop(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(
                                newProduct: widget.product,
                              ),
                            ),
                          );
                        } else {
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
                                        Center(
                                          child: Text(
                                            "Les champs Prix et Quantité doivent être des valeurs numériques",
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
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(10.0),
                                                  height: 40.5,
                                                  width: 110,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    color: Colors.red
                                                        .withOpacity(.3),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "D'accord",
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
                        }
                      } else {
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
                                        height: 16,
                                      ),
                                      Center(
                                        child: Text(
                                          "Veuillez remplir tous les champs",
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
                                                Navigator.of(context).pop();
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(10.0),
                                                height: 40.5,
                                                width: 110,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  color: Colors.red
                                                      .withOpacity(.3),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "D'accord",
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
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
