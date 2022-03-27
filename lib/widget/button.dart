// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:ordering_services/constants/app_colors.dart';

class DefaultButton extends StatelessWidget {
  DefaultButton({
    Key key,
    this.text,
    this.press,
  }) : super(key: key);
  String text;
  Function() press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: AppColors.greenDark,
        onPressed: press,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}
