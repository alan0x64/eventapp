import 'package:fluttertoast/fluttertoast.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/net/auth.dart';
import 'package:flutter/material.dart';
import 'package:org/screens/login.dart';

class Console {
  static logError(String str) {
    return "\n---------------ERROR-------------\nstr\n----------------------------\n";
  }

  static log(dynamic str) {
    print("\n----------------------------\nstr\n----------------------------\n") ;
  }
}

Future<dynamic> runFun(context, Function requestCallback,
    Function mapResponseCallback, int userOrOrgMode) async {
  try {
    if (await checkOrRenewTokens() == false) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(userOrOrgMode),
          ));
    }
    Response res = await requestCallback();
    if (res.statusCode != 200) throw Exception(Console.logError(res.status));
    return mapResponseCallback(res);
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
    throw Exception(Console.logError(e.toString()));
  }
}

List<dynamic> mapObjs(List<dynamic> res, Function mapperCallback) {
  List<dynamic> listOfObj = [];
  for (var i = 0; i < res.length; i++) {
    listOfObj[i] = mapperCallback(res[i]);
  }
  return listOfObj;
}
