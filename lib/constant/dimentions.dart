import 'package:flutter/material.dart';

class Dimentions {
  static double screenHight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double hightPercentage(BuildContext context, double percentage) =>
      screenHight(context) * percentage / 100;
  static double widthPercentage(BuildContext context, double percentage) =>
      screenWidth(context) * percentage / 100;
  static double fontPercentage(BuildContext context, double percentage) =>
      screenHight(context) * percentage / 100;
  static double radiusPercentage(BuildContext context, double percentage) =>
      screenHight(context) * percentage / 100;
}
