import 'package:eums/gen/fonts.gen.dart';
import 'package:flutter/material.dart';

class StyleFont {
  static const double _fontSizeScale = 0;

  static TextStyle bold([double fontSize = 16]) {
    fontSize += _fontSizeScale;
    return TextStyle(
      fontFamily: FontFamily.notoSansKRBold,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
    );
  }

  static TextStyle medium([double fontSize = 16]) {
    fontSize += _fontSizeScale;
    return TextStyle(
      fontFamily: FontFamily.notoSansKRMedium,
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
    );
  }

  static TextStyle regular([double fontSize = 16]) {
    fontSize += _fontSizeScale;
    return TextStyle(
      fontFamily: FontFamily.notoSansKRRegular,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
    );
  }
}
