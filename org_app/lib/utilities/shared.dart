import 'package:flutter/foundation.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/net/auth.dart';
import 'package:flutter/material.dart';
import 'package:org/screens/login.dart';

class Console {
  static logError(String str) {
    return "\n---------------ERROR-------------\n$str\n----------------------------\n";
  }

  static log(dynamic str) {
    if (kDebugMode) {
      print(
          "\n----------------------------\n$str\n----------------------------\n");
    }
  }
}

Future<dynamic> runFun(context, Function requestCallback) async {
  if (await checkOrRenewTokens() == false) {
    gotoClear(context, const LoginScreen());
  }
  Response res = await requestCallback();
  if (res.statusCode != 200) Console.logError(res.status);
  return res;
}

List<dynamic> mapObjs(List<dynamic> res, Function mapperCallback) {
  List<dynamic> listOfObj = [];
  for (var i = 0; i < res.length; i++) {
    listOfObj[i] = mapperCallback(res[i]);
  }
  return listOfObj;
}

void snackbar(BuildContext context, String text, int duration) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    dismissDirection: DismissDirection.up,
    content: Text(text),
    duration: Duration(seconds: duration),
  ));
}

void goto(context, Widget screen) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => screen,
    ),
  );
}

void gotoClear(context, Widget screen) {
  Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (context) => screen), (route) => false);
}
