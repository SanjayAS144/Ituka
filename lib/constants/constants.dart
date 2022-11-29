import 'dart:ui';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';


////////////////////////////////////////////////////

//One Signal Notification app Id
String kAppId = "7d108336-42a4-4e9f-9a23-6105dd125a74";
////////////////////////////////////////////////////


//Main Theme Color
Color kPrimaryColor = Color(0xff9976D2);
Color kPrimaryLightColor = Color(0xffe9e5ff);
Color kPrimaryDarkColor = Color(0xff3D3270);

List<List<Color>> cardColorsHome = [
  [Color(0xff3D3270), Color(0xfff6f5fb)] ,
  [Color(0xff4D9A9A), Color(0xffE0F4F4)],
  [Color(0xffFF6550), Color(0xffFFF3F1)]];


TextStyle headTextStyle() {
  return GoogleFonts.montserrat(
    fontSize: 22.0,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w500,
    color: kPrimaryDarkColor,
  );
}

TextStyle subHeadTextStyle() {
  return GoogleFonts.montserrat(
    fontSize: 16,color: kPrimaryDarkColor.withOpacity(0.7),
    letterSpacing: 1.2,
  );
}

TextStyle cardTitleTextStyle() {
  return GoogleFonts.montserrat(
    fontSize: 21,
    color: kPrimaryDarkColor,
    letterSpacing: 1.2,
  );
}
TextStyle cardSubHeadTextStyle() {
  return GoogleFonts.montserrat(
    fontSize: 10,
    color: kPrimaryDarkColor.withOpacity(0.6),
    letterSpacing: 1.2,
  );
}