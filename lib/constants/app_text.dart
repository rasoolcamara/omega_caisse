import 'package:flutter/cupertino.dart';

TextStyle regularLightTextStyle(Color color) {
  return TextStyle(
      fontWeight: FontWeight.w300,
      color: color,
      fontSize: 16,
      decoration: TextDecoration.none);
}

TextStyle regularBoldTextStyle(Color color) {
  return TextStyle(
      fontWeight: FontWeight.bold,
      color: color,
      decoration: TextDecoration.none,
      fontSize: 16);
}

TextStyle mediumLightTextStyle(Color color) {
  return TextStyle(
      fontWeight: FontWeight.w300,
      color: color,
      decoration: TextDecoration.none,
      fontSize: 14);
}

TextStyle tabTextStyle() {
  return TextStyle(
      fontWeight: FontWeight.w300,
      decoration: TextDecoration.none,
      fontSize: 14);
}

TextStyle mediumBoldTextStyle(Color color) {
  return TextStyle(
      fontWeight: FontWeight.bold,
      color: color,
      decoration: TextDecoration.none,
      fontSize: 14);
}

TextStyle smallLightTextStyle(Color color) {
  return TextStyle(
      fontWeight: FontWeight.w300,
      color: color,
      decoration: TextDecoration.none,
      fontSize: 12);
}

TextStyle smallBoldTextStyle(Color color) {
  return TextStyle(
      fontWeight: FontWeight.bold,
      color: color,
      decoration: TextDecoration.none,
      fontSize: 12);
}

TextStyle bigLightTextStyle(Color color) {
  return TextStyle(
      fontWeight: FontWeight.w300,
      color: color,
      decoration: TextDecoration.none,
      fontSize: 24);
}

TextStyle bigBoldTextStyle(Color color) {
  return TextStyle(
    fontWeight: FontWeight.bold,
    color: color,
    decoration: TextDecoration.none,
    fontSize: 24,
  );
}
