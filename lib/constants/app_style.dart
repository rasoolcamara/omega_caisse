import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'app_colors.dart';
import 'app_text.dart';



AppBar mainAppBar(String title) {
  return AppBar(
    centerTitle: true,
    title: Text(title,  style: regularLightTextStyle(AppColors.ACCENT_COLOR),),
    backgroundColor: AppColors.PRIMARY_COLOR,
    iconTheme: IconThemeData(color: AppColors.ACCENT_COLOR),
  );
}

Center loadingLayout() {
  return Center(
    child: SpinKitFadingCircle(
          color: AppColors.PRIMARY_COLOR,
          size: 32.0,
        )
  );
}
InputDecoration textInputDecoration(String hint) {
  return InputDecoration(
    fillColor: AppColors.PRIMARY_COLOR_DARK,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding:
      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
  hintText: hint);
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      focusColor: AppColors.PRIMARY_COLOR_DARK,
      labelText: hintText,
      hintText: hintText,
      hintStyle: TextStyle(color: AppColors.PRIMARY_COLOR_DARK),
      focusedBorder:OutlineInputBorder(
        borderRadius:
        BorderRadius.all(Radius.circular(8.0)),

        borderSide: BorderSide(color: AppColors.PRIMARY_COLOR_DARK),
      ),
      border:OutlineInputBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(8.0))));
}

RoundedRectangleBorder buttonMainShape(){
  return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
      side: BorderSide(color: AppColors.PRIMARY_COLOR_DARK)
  );
}



InputDecoration searchTextDecoration (){
  return InputDecoration(
      focusColor: AppColors.PRIMARY_COLOR_DARK,
      labelText: "Rechercher",
      hintText: "Rechercher",
      prefixIcon: Icon(Icons.search),
      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.all(Radius.circular(16.0)),

        borderSide: BorderSide(color: AppColors.PRIMARY_COLOR_DARK),
      ),
      border: OutlineInputBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(16.0))));
}
