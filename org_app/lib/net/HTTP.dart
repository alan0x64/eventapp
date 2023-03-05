// ignore_for_file: non_constant_identifier_names, unused_field, unnecessary_this, file_names

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:org/net/auth.dart';

import '../utilities/shared.dart';

class Response {
  Response({
    this.status = "ERROR",
    this.statusCode = 500,
    this.timeStamp = "00:00:00",
    this.data = const {},
  });

  String status;
  int statusCode;
  String timeStamp;
  Map<String, dynamic> data;
  static const errorStatus = [400, 500];
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

Future<Response> multipartRequest(
    {
    String token = 'AT',
    required Map<String, dynamic> data,
    required String url,
    required String method,
    required XFile? file,
    required XFile? file2,
    required String filefield1,
    required String filefield2,
    required http.MultipartRequest Function(
            http.MultipartRequest req, Map<String, dynamic> data)
        addFields}) async {
  try {
    var request = http.MultipartRequest(method, Uri.parse(url));
    Map<String, String> headers = await Header(1, token);

    if (file != null) {
      var pic = http.MultipartFile.fromBytes(
        filefield1,
        await file.readAsBytes(),
        filename: file.name,
      );
      request.files.add(pic);
    }

    if (file2 != null) {
      var pic2 = http.MultipartFile.fromBytes(
        filefield2,
        await file2.readAsBytes(),
        filename: file2.name,
      );
      request.files.add(pic2);
    }

    request = addFields(request, data);

    for (String key in headers.keys) {
      request.headers[key] = headers[key] as String;
    }

    return encodeRES(await http.Response.fromStream(await request.send()));
  } catch (e) {
    Console.log(e);
    throw Exception("ERROR\n$e");
  }
}
