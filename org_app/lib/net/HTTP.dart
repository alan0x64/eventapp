// ignore_for_file: non_constant_identifier_names, unused_field, unnecessary_this, file_names

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:org/net/auth.dart';

class Response {
Response({
    this.status="ERROR",
    this.statusCode=500,
    this.timeStamp= "00:00:00",
    this.data = const {},
  });

  String status;
  int statusCode;
  String timeStamp;
  Map<String, dynamic> data;
}

Future<Map<String, String>> Header(int json_or_form, String keyToAdd) async {
  Map<String, String> header = {};

  if (json_or_form == 0) {
    header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }
  if (json_or_form == 1) {
    header = {
      'Content-Type': 'multipart/form-data; charset=UTF-8',
    };
  }

  if (keyToAdd == '0') return header;

  header['authorization'] = await getToken(keyToAdd);
  return header;
}

Response encodeRES(http.Response res) {
  Map<String, dynamic> data = jsonDecode(res.body);
  return Response(
    status: data['status'],
    statusCode: data['statusCode'],
    timeStamp: data['timeStamp'].toString(),
    data: data['data'] ?? {"msg": "DATA IS EMPTY"},
  );
}

Future<dynamic> GET(
  String url,
  int json_or_form,
  String keyToAdd,
) async {
  return encodeRES(await http.get(Uri.parse(url),
      headers: await Header(json_or_form, keyToAdd)));
}

Future<Response> POST(
    String url, int json_or_form, String keyToAdd, dynamic body) async {
  return encodeRES(await http.post(Uri.parse(url),
      headers: await Header(json_or_form, keyToAdd), body: jsonEncode(body)));
}

Future<Response> PATCH(
    String url, int json_or_form, String keyToAdd, dynamic body) async {
  return encodeRES(await http.patch(Uri.parse(url),
      headers: await Header(json_or_form, keyToAdd), body: jsonEncode(body)));
}

Future<Response> PUT(
    String url, int json_or_form, String keyToAdd, dynamic body) async {
  return encodeRES(await http.put(Uri.parse(url),
      headers: await Header(json_or_form, keyToAdd), body: jsonEncode(body)));
}

Future<Response> DELETE(
    String url, int json_or_form, String keyToAdd, dynamic body) async {
  return encodeRES(await http.delete(Uri.parse(url),
      headers: await Header(json_or_form, keyToAdd), body: jsonEncode(body)));
}
