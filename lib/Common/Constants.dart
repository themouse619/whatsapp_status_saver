import 'dart:ui';

import 'package:flutter/material.dart';

class Session {
  static bool deleteSwitch = false;
  static bool downloadPathSet = false;
  static const String downloadPath = 'downloadPath';
}
class Constants{
  static const String feedbackEmail='yash.vinchu619@gmail.com';

}

Map<int, Color> appPrimaryColors = {
  50: Color.fromRGBO(40, 53, 147, .1),
  100: Color.fromRGBO(40, 53, 147, .2),
  200: Color.fromRGBO(40, 53, 147, .3),
  300: Color.fromRGBO(40, 53, 147, .4),
  400: Color.fromRGBO(40, 53, 147, .5),
  500: Color.fromRGBO(40, 53, 147, .6),
  600: Color.fromRGBO(40, 53, 147, .7),
  700: Color.fromRGBO(40, 53, 147, .8),
  800: Color.fromRGBO(40, 53, 147, .9),
  900: Color.fromRGBO(40, 53, 147, 1)
};

MaterialColor appPrimaryMaterialColor =
MaterialColor(0xFF283593, appPrimaryColors);
