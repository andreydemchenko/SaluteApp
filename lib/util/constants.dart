import 'package:flutter/material.dart';

const kDefaultPadding = EdgeInsets.symmetric(
  vertical: 36.0,
  horizontal: 26.0,
);

const kPrimaryColor = Color(0xFFFFFFFF);
const kSecondaryColor = Color(0xFF1F89F8);
const kAccentColor = Color(0xFFABBACA);
const kBlueColor = Color(0xFFE8F1FC);

const kColorPrimaryVariant = Color(0xFF424242);

const kRedColor = Color(0xFFF16B6B);

const kBackgroundColor = Color(0xFF1D1C1C);
const kBackgroundColorInt = 0xFF1D1C1C;
const kFontFamily = 'Nunito';

const kTextTheme = TextTheme(
  displayLarge: TextStyle(),
  bodyLarge: TextStyle(),
  bodyMedium: TextStyle(),
);

const kButtonTheme = ButtonThemeData(
  splashColor: Colors.transparent,
  padding: EdgeInsets.symmetric(vertical: 14),
  buttonColor: Color(0xFFB1A898),
  textTheme: ButtonTextTheme.accent,
  highlightColor: Color.fromRGBO(0, 0, 0, .3),
  focusColor: Color.fromRGBO(0, 0, 0, .3),
);

const Map<int, Color> kThemeMaterialColor = {
  50: Color.fromRGBO(0, 0, 0, .1),
  100: Color.fromRGBO(0, 0, 0, .2),
  200: Color.fromRGBO(0, 0, 0, .3),
  300: Color.fromRGBO(0, 0, 0, .4),
  000: Color.fromRGBO(0, 0, 0, .5),
  500: Color.fromRGBO(0, 0, 0, .6),
  600: Color.fromRGBO(0, 0, 0, .7),
  700: Color.fromRGBO(0, 0, 0, .8),
  800: Color.fromRGBO(0, 0, 0, .9),
  900: Color.fromRGBO(0, 0, 0, 1),
};
