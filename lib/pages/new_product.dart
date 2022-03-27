// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/constants/app_text.dart';
import 'package:ordering_services/widget/button.dart';

class NewProductPage extends StatefulWidget {
  @override
  NewProductPageState createState() {
    return NewProductPageState();
  }
}

// Create a corresponding State class. This class holds data related to the form.
class NewProductPageState extends State<NewProductPage> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

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
                decoration: const InputDecoration(
                  icon: const Icon(
                    Icons.account_tree_outlined,
                    color: AppColors.greenDark,
                  ),
                  hintText: 'Nom du produit',
                  labelText: 'Nom',
                  labelStyle: TextStyle(
                    color: AppColors.greenDark,
                  ),
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.greenDark,
                  ),
                  hintText: 'Prix du produit',
                  labelText: 'Prix',
                  labelStyle: TextStyle(
                    color: AppColors.greenDark,
                  ),
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(
                    Icons.add_box_outlined,
                    color: AppColors.greenDark,
                  ),
                  hintText: 'Quantité',
                  labelText: 'Quantité',
                  labelStyle: TextStyle(
                    color: AppColors.greenDark,
                  ),
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
                      Navigator.pop(context);
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
