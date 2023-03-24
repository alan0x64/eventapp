// ALL
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String devServer = "";
String authServer = "";

void host(bool production) {
  // Production Server
  if (production == true) {
    devServer = dotenv.get('devproductionIP');
    authServer = dotenv.get('authproductionIP');
    return;
  }
  // Android EMU
  // https://developer.android.com/studio/run/emulator-networking
  if (Platform.isAndroid) {
    devServer = "http://10.0.2.2:3000";
    authServer = "http://10.0.2.2:8000/RT";
    return;
  }

  //Every Other Platform
  devServer = "http://localhost:3000";
  authServer = "http://localhost:8000/RT";
}