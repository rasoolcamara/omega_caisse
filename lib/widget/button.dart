// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:auto_size_text/auto_size_text.dart';
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
        child: AutoSizeText(
          text,
          maxLines: 1,
          maxFontSize: 15,
          minFontSize: 12,
          textScaleFactor: 1.0,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            decoration: TextDecoration.none,
            fontSize: 13,
            letterSpacing: 1.0,
            wordSpacing: 1.0,
          ),
        ),
        //  Text(
        //   text,
        //   style: TextStyle(
        //     fontWeight: FontWeight.w500,
        //     color: Colors.white,
        //     fontSize: 13.0,
        //   ),
        // ),
      ),
    );
  }
}
