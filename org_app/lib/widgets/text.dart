import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class AppText extends StatelessWidget {
  String text;
  double size;
  FontWeight fw;
  Color textColors;
  TextStyle? textStyle = GoogleFonts.merriweather();
  AppText(
      {required this.text,
      this.size = 10,
      this.fw = FontWeight.normal,
      this.textColors = Colors.black,
      this.textStyle,
      super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textStyle ??
          TextStyle(fontSize: size, fontWeight: fw, color: textColors),
    );
  }
}
