import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/net/auth.dart';
import 'package:org/screens/org/login.dart';
import 'package:org/servers.dart';
import 'package:org/utilities/shared.dart';

class Org {
  final String orgPic;
  final String orgBackgroundPic;
  final String orgName;
  final String email;
  final String password;
  final int phoneNumber;
  final String bio;
  final int orgtype;
  final String location;
  final List<String> orgEvents;

  Org({
    required this.orgPic,
    required this.orgBackgroundPic,
    required this.orgName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.bio = "None",
    this.orgtype = 0,
    this.location = "None",
    required this.orgEvents,
  });
}

Future<Org> runFun(context, Function cb) async {
  try {
    if (await checkOrRenewTokens() == false) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ));
    }
    Response res = await cb();
    if (res.statusCode != 200) throw Exception(Console.logError(res.status));
    return Org(
        orgPic: res.data['orgPic'],
        orgBackgroundPic: res.data['orgBackgroundPic'],
        orgName: res.data['orgName'],
        email: res.data['email'],
        password: res.data['password'],
        phoneNumber: res.data['phoneNumber'],
        orgEvents: res.data['orgEvents']);
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
    throw Exception(Console.logError(e.toString()));
  }
}

// GET
Future<Response> getProfile() async {
  return await GET('$devServer/org/profile', 0, 'AT');
}

Future<Response> getOrgEvents() async {
  return await GET('$devServer/org/events', 0, 'AT');
}

// POST
Future<Response> login(Map<String, dynamic> data) async {
  return await POST('$devServer/org/login', 0, '0', data);
}

Future<Response> logout() async {
  return await POST('$devServer/org/logout', 0, 'RT', {});
}

Future<Response> singUp(Map<String, dynamic> data) async {
  return await POST('$devServer/org/register', 1, '0', data);
}

Future<Response> blockUser(String userId, String eventId) async {
  return await POST('$devServer/org/$userId/$eventId', 0, 'AT', {});
}

// PATCH
Future<Response> updateProfile(Map<String, dynamic> data) async {
  return await PATCH('$devServer/org/update', 1, 'AT', data);
}

// DELETE
Future<Response> deleteAccount() async {
  return await DELETE('$devServer/org/delete', 0, 'AT', {});
}

Future<Response> unblockUser(String userId, String eventId) async {
  return await DELETE('$devServer/org/$userId/$eventId', 0, 'AT', {});
}
