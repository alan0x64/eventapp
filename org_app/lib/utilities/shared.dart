// ignore_for_file: non_constant_identifier_names, null_argument_to_non_null_type, depend_on_referenced_packages

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/event.dart';
import '../models/org.dart';
import '../models/user.dart';
import '../net/HTTP.dart';
import '../net/auth.dart';
import '../screens/login.dart';
import '../server.dart';
import '../widgets/dialog.dart';
import 'providers.dart';

typedef ResCallback = Future<Response> Function();
typedef FORMKEY = GlobalKey<FormBuilderState>;

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
    listOfObj.add(mapperCallback(res[i]));
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

void moveBack(context, int steps) {
  Navigator.popUntil(context, (route) => steps-- == 0);
}

void gotoNamed(BuildContext? context, String screen, dynamic arg) {
  Navigator.pushNamed(context!, screen, arguments: arg);
}

void gotoClear(context, Widget screen, {bool x = false}) {
  Navigator.pushAndRemoveUntil(
      context, MaterialPageRoute(builder: (context) => screen), (route) => x);
}

AppBar buildAppBar(BuildContext context, String title,
    {bool showdialog = true,
    Widget? button,
    bool search = false,
    SearchDelegate? searchWidget}) {
  return AppBar(
    title: Text(title),
    leading: button,
    elevation: 0,
    actions: [
      if (search)
        IconButton(
            onPressed: () {
              showSearch(context: context, delegate: searchWidget!);
            },
            icon: const Icon(Icons.search)),
      IconButton(
        icon: const Icon(CupertinoIcons.moon_stars),
        onPressed: () {
          try {
            if (showdialog) {
              showDialog(
                  context: context,
                  builder: (context) => CustomDialog(
                        bigText: "Sure Wanna Change Theme?",
                        smallerText: "All Unsaved Chnages Will Be Lost!",
                        quit: false,
                        fun: () async {
                          ThemeProvider.controllerOf(context).nextTheme();
                          Navigator.pop(context);
                          return await Future.value(Response());
                        },
                      ));
            } else {
              ThemeProvider.controllerOf(context).nextTheme();
            }
          } catch (e) {
            Console.log(e);
          }
        },
      )
    ],
  );
}

void FormRequestHandler({
  bool create = false,
  required int org_event_user,
  required FORMKEY formKey,
  required VoidCallback setState,
  required BuildContext context,
  required Map<String, dynamic> formdata,
  required Future<Response> Function(
          Map<String, dynamic> formdata, Response res)
      requestHandler,
}) async {
  Response res = Response();

  if (!formKey.currentState!.validate()) return;

  if (org_event_user != 2 &&
      (formdata['location'].isEmpty || formdata['location'] == "0.0,0.0")) {
    return org_event_user == 0
        ? snackbar(context, "Headquarters Cannot Be Empty", 2)
        : snackbar(context, "Location Cannot Be Empty", 2);
  }

  if (org_event_user != 1 && create) {
    formdata['password'] = formKey.currentState!.fields['password']!.value;
  }

  res = await requestHandler(formdata, res);

  if (res.statusCode != 200 && res.statusCode != 201) {
    Timer(const Duration(seconds: 1), (() {
      snackbar(context, "Request Faild", 2);
    }));
    dynamic x = res.data;
    throw Exception("Error When Trying to CURD\n$x");
  }

  if (res.statusCode == 200) {
    setState();
  }
  Timer(const Duration(seconds: 1), (() {
    snackbar(context, res.data['msg'], 2);
  }));
}

Map<String, dynamic> getOrgFromForm(
  BuildContext context,
  FORMKEY formKey,
) {
  return {
    'orgName': formKey.currentState!.fields['name']!.value,
    'email': formKey.currentState!.fields['email']!.value,
    'phoneNumber': formKey.currentState!.fields['phoneNumber']!.value,
    'bio': formKey.currentState!.fields['bio']!.value,
    'org_type': formKey.currentState!.fields['org_type']!.value,
    'website': formKey.currentState!.fields['website']!.value,
    'socialMedia': formKey.currentState!.fields['socialMedia']!.value,
    'location': getLocationString(context, 0),
  };
}

Map<String, dynamic> getEventFromForm(BuildContext context, FORMKEY formKey,
    {String location = ''}) {
  if (location.isEmpty || getLocationString(context, 1) != "0.0,0.0") {
    location = getLocationString(context, 1);
  }

  return {
    'title': formKey.currentState!.fields['title']!.value,
    'description': formKey.currentState!.fields['description']!.value,
    'eventType': formKey.currentState!.fields['eventType']!.value.toString(),
    'startDateTime':
        formKey.currentState!.fields['startDateTime']!.value.toString(),
    'endDateTime':
        formKey.currentState!.fields['endDateTime']!.value.toString(),
    'minAttendanceTime':
        formKey.currentState!.fields['minAttendanceTime']!.value.toString(),
    'seats': formKey.currentState!.fields['seats']!.value.toString(),
    'location': location,
  };
}

void validateLocationBeforeUpdating(context, String location, int org_event) {
  Console.log(location);
  List<String> locationFromDB = getLocationList(context, location);
  String stringLocation = getLocationString(context, org_event);
  double lat = double.parse(locationFromDB[0]);
  double lng = double.parse(locationFromDB[1]);
  LatLng newLocation = LatLng(lat, lng);

  if (stringLocation.isEmpty || stringLocation == "0.0,0.0") {
    org_event == 0
        ? getFromProvider<LocationProvider>(
            context, (provider) => provider.setOrgLocation(newLocation))
        : getFromProvider<LocationProvider>(
            context, (provider) => provider.setOrgLocation(newLocation));
  }
}

String getLocationString(BuildContext context, int org_event) {
  LatLng? loc = getFromProvider<LocationProvider>(
      context, (provider) => provider[org_event]);
  if (loc == null) return "0.0,0.0";
  String lat = loc.latitude.toString();
  String lng = loc.longitude.toString();
  return "$lat,$lng";
}

dynamic getFromProvider<T>(
    BuildContext context, dynamic Function(T provider) fun) {
  return fun(Provider.of<T>(context, listen: false));
}

List<String> getLocationList(BuildContext context, String loc) {
  String lat = loc.substring(0, loc.indexOf(','));
  String lng = loc.substring(loc.indexOf(',') + 1);
  return [lat, lng];
}

Widget buildcoverimage(XFile? localBackground, String netBackground) {
  return Material(
      color: Colors.transparent,
      child: localBackground != null
          ? loadImageFile(localBackground)
          : loadImageNet(netBackground));
}

Widget loadImageFile(XFile image, {bool profile = false}) {
  double hight = 180;
  double width = double.infinity;
  BoxFit fit = BoxFit.fill;

  if (profile) {
    hight = 128;
    width = 128;
    fit = BoxFit.cover;
  }

  return SizedBox(
      width: width,
      height: hight,
      child: FittedBox(fit: fit, child: Image.file(File(image.path))));
}

Ink loadImageNet(String path, {bool profile = false}) {
  if (path.isEmpty) {
    path = "$devServer/uploads/plus.png";
  }
  double hight = 180;
  double width = double.infinity;
  BoxFit fit = BoxFit.cover;

  if (profile) {
    hight = 128;
    width = 128;
  }

  return Ink.image(
    image: NetworkImage(path),
    fit: fit,
    width: width,
    height: hight,
  );
}

Widget buildEditIcon(Color color, EdgeInsets x, bool isEdit, VoidCallback fun) {
  return Container(
    margin: x,
    height: 35,
    width: 35,
    child: buildCirle(
      color: Colors.white,
      all: 3,
      child: buildCirle(
        color: color,
        all: 3,
        child: IconButton(
          onPressed: fun,
          color: Colors.white,
          icon: Icon(
            isEdit ? Icons.add_a_photo : Icons.edit,
            size: 20,
          ),
        ),
      ),
    ),
  );
}

Widget buildCirle({
  required Widget child,
  required double all,
  required Color color,
}) {
  return ClipOval(
    child: Container(
      // padding: EdgeInsets.all(all),
      color: color,
      child: child,
    ),
  );
}

Widget buildImage({required XFile? profile, required String imagepath}) {
  return Container(
    margin: const EdgeInsets.fromLTRB(140, 80, 0, 0),
    child: ClipOval(
      child: Material(
        color: Colors.transparent,
        child: profile != null
            ? loadImageFile(profile, profile: true)
            : loadImageNet(imagepath, profile: true),
      ),
    ),
  );
}

void ResetForm({
  required BuildContext context,
  required FORMKEY formkey,
  required int org_event_user,
  required XFile? fileOne,
  required XFile? fileTwo,
}) {
  fileOne = null;
  fileTwo = null;
  org_event_user == 0
      ? getFromProvider<LocationProvider>(
          context, (provider) => provider.setOrgLocation(LatLng(0, 0)))
      : getFromProvider<LocationProvider>(
          context, (provider) => provider.setEventLocation(LatLng(0, 0)));
  formkey.currentState!.reset();
}

Event mapEvent(Map<String, dynamic>? data) {
  if (data == null) {
    return const Event();
  }

  String title = data['title'] ?? "";
  String description = data['description'] ?? '';

  int seats = int.parse(
      data['seats'].toString().isEmpty || data['seats'] == null
          ? "0"
          : data['seats']);
  int status = int.parse(
      data['status'].toString().isEmpty || data['status'] == null
          ? "0"
          : data['status']);
  int eventType = int.parse(
      data['eventType'].toString().isEmpty || data['eventType'] == null
          ? '0'
          : data['eventType']);
  int minAttendanceTime = int.parse(
      data['minAttendanceTime'].toString().isEmpty ||
              data['minAttendanceTime'] == null
          ? '0'
          : data['minAttendanceTime']);
  String startDateTime =
      data['startDateTime'].toString().isEmpty || data['startDateTime'] == null
          ? ""
          : data['startDateTime'].toString();
  String endDateTime =
      data['endDateTime'].toString().isEmpty || data['endDateTime'] == null
          ? ""
          : data['endDateTime'].toString();

  return Event(
      title: title,
      description: description,
      seats: seats,
      status: status,
      eventType: eventType,
      minAttendanceTime: minAttendanceTime,
      startDateTime: startDateTime,
      endDateTime: endDateTime);
}

buildTitle(
  String textOne,
  String textTwo,
) {
  return Column(
    children: [
      Text(
        textOne,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      const SizedBox(
        height: 4,
      ),
      Text(
        textTwo,
        style: const TextStyle(color: Colors.grey),
      )
    ],
  );
}

Widget buildViewInfo(String name, dynamic text, {Color? xcolor}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 48),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          text.toString(),
          style: TextStyle(color: xcolor, fontSize: 18, height: 1.4),
        )
      ],
    ),
  );
}

String timeTo12(String date) {
  var formatter = DateFormat('yyyy-MM-dd hh:mm:ss.SSS');
  var dateTime = formatter.parse(date);
  formatter = DateFormat('hh:mm a');
  return formatter.format(dateTime);
}

int getTimeInMin(String date) {
  if (DateTime.tryParse(date) == null) return 0;
  var time = DateTime.tryParse(date);
  return ((time!.microsecondsSinceEpoch / 1000000) / 60).floor();
}

void showOnMap(BuildContext context, String location) {
  List<String> l = getLocationList(context, location);
  String lat = l[0];
  String lng = l[1];
  Console.log("https://www.google.com/maps?q=$lat,$lng");
  launchUrl(Uri.parse('https://www.google.com/maps?q=$lat,$lng'));
}

Future<Response> QRCheckin(
  BuildContext context,
  String eventId,
  int scan,
  Future<String> Function() getString,
) async {
  Console.log("mode: $scan");
  Response res = Response();
  res = await runFun(
    context,
    () async {
      if (scan == 0) {
        return await checkIn(eventId, await getString());
      } else {
        return await checkOut(eventId, await getString());
      }
    },
  );
  return res;
}

int getTheme(context) {
  return ThemeProvider.themeOf(context).id == "default_dark_theme" ? 0 : 1;
}

String? validateAttendanceTime(timeInMin, GlobalKey<FormBuilderState> formKey) {
  DateTime start = formKey.currentState!.fields['startDateTime']!.value;
  DateTime end = formKey.currentState!.fields['endDateTime']!.value;
  if (int.parse(timeInMin) >
      ((end.millisecondsSinceEpoch - start.millisecondsSinceEpoch) / 1000) /
          60) {
    return "Attendance Time Is Bigger Then Event Time";
  }
  return null;
}

bool validateStartEnd(
    BuildContext context, GlobalKey<FormBuilderState> formKey) {
  DateTime start = formKey.currentState!.fields['startDateTime']!.value;
  DateTime end = formKey.currentState!.fields['endDateTime']!.value;

  if (start.millisecondsSinceEpoch >= end.millisecondsSinceEpoch) {
    snackbar(
        context,
        "The start time should not be later than the end time, and the event time should not be earlier than the start time",
        2);
    return true;
  }
  return false;
}

bool didFieldsChange(
    {required BuildContext context,
    required GlobalKey<FormBuilderState> formkey,
    required dynamic object,
    required Map<String, dynamic> objectMap,
    required int org_event_user}) {
  for (var key in objectMap.keys) {
    if (formkey.currentState!.fields[key]?.value.toString() != objectMap[key]) {
      return true;
    }
  }

  if (org_event_user != 2) if (object.location !=getLocationString(context, org_event_user)) return true;

  return false;
}
