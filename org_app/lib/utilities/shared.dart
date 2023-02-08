// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:org/models/org.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/net/auth.dart';
import 'package:org/screens/login.dart';
import 'package:org/utilities/providers.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';

class Console {
  static logError(String str) {
    return "\n---------------ERROR-------------\n$str\n----------------------------\n";
  }

  static log(dynamic str) {
    if (kDebugMode) {
      print("----------------------------\n$str\n----------------------------");
    }
  }
}

typedef ResCallback = Future<Response> Function();

Future<dynamic> runFun(context, ResCallback requestCallback) async {
  try {
    Response res;
    if (await checkOrRenewTokens() == false) {
      await logout();
      await clearTokens();
      gotoClear(context, const LoginScreen());
    }
    res = await requestCallback();
    if (res.statusCode != 200) Console.logError(res.status);
    return res;
  } catch (e) {
    String errorMessage = e.toString().split('\n').take(5).join('\n');
    Console.logError(errorMessage);
  }
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

AppBar buildAppBar(BuildContext context, String title, {Widget? button}) {
  return AppBar(
    title: Text(title),
    leading: button,
    elevation: 0,
    actions: [
      IconButton(
        icon: const Icon(CupertinoIcons.moon_stars),
        onPressed: () {
          ThemeProvider.controllerOf(context).nextTheme();
        },
      )
    ],
  );
}

void FormRequestHandler(
    {bool singup = false,
    Org orgdata = const Org(),
    required GlobalKey<FormBuilderState> formKey,
    required Future<Response> Function(Map<String, dynamic> data, Response res)
        requestHandler,
    required VoidCallback setState,
    required BuildContext context,
    required XFile? profileImage,
    required XFile? backgroundImage}) async {
  Response res = Response();

  if (!singup) {
    List<String> x = getLocationList(context, orgdata.location);
    if (getLocationString(context).isEmpty ||
        getLocationString(context) == "0.0,0.0") {
      Provider.of<LocationProvider>(context, listen: false)
          .setOrgLocation(LatLng(double.parse(x[0]), double.parse(x[1])));
    }
  }

  if (!formKey.currentState!.validate()) return;

  String name = formKey.currentState!.fields['name']!.value;
  String email = formKey.currentState!.fields['email']!.value;
  String phoneNumber = formKey.currentState!.fields['phoneNumber']!.value;
  String bio = formKey.currentState!.fields['bio']!.value;
  int oryType = formKey.currentState!.fields['org_type']!.value;
  String website = formKey.currentState!.fields['website']!.value;
  String socialMedia = formKey.currentState!.fields['socialMedia']!.value;

  String location = getLocationString(context);
  if (location.isEmpty || location == "0.0,0.0") {
    return snackbar(context, "Headquarters Cannot Be Empty", 2);
  }

  Map<String, dynamic> data = {
    "orgdata": {
      'orgName': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'location': location,
      'bio': bio,
      'org_type': oryType,
      'website': website,
      'socialMedia': socialMedia,
    }
  };
  if (singup) {
    data['orgdata']['password'] =
        formKey.currentState!.fields['password']!.value;
  }

  res = await requestHandler(data, res);

  if (res.statusCode != 200 && res.statusCode != 201) {
    Timer(const Duration(seconds: 1), (() {
      snackbar(context, "Request Faild", 2);
    }));
    dynamic x = res.data;
    throw Exception("Error When Trying to SingUp-Update\n$x");
  }

  if (res.statusCode == 200) {
    setState();
  }
  Timer(const Duration(seconds: 1), (() {
    snackbar(context, res.data['msg'], 2);
  }));
}

String getLocationString(BuildContext context) {
  LatLng? loc =
      Provider.of<LocationProvider>(context, listen: false).orgLocation;
  if (loc == null) return "";
  String lat = loc.latitude.toString();
  String lng = loc.longitude.toString();
  return "$lat,$lng";
}

List<String> getLocationList(BuildContext context, String loc) {
  String lat = loc.substring(0, loc.indexOf(','));
  String lng = loc.substring(loc.indexOf(',') + 1);
  return [lat, lng];
}
