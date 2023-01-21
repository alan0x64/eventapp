// ignore_for_file: non_constant_identifier_names, unused_field, unnecessary_this, file_names
import 'package:http/http.dart' as http;
import 'dart:convert';

class HTTP {

 static Map<String, String> Header( int json_or_form) {
    Map<String, String> header = {};
    if (json_or_form == 0) header = {'Content-Type': 'application/json; charset=UTF-8',};
    if (json_or_form == 1) header = {'Content-Type': 'multipart/form-data; charset=UTF-8',};

    //get token from strage 
    //
    // header['Authorization'] = "Bearer $token";

    return header;
  }

  static dynamic encodeRES(http.Response res) {
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("400 Error Code ");
    }
  }

  static Future<dynamic> GET(String url, Map<String, String> headers) async {
    dynamic res = await http.get(url as Uri, headers: headers);
    return encodeRES(res);
  }

  static Future<dynamic> POST(
      String url, Map<String, String> headers, dynamic body) async {
    dynamic res = http.post(url as Uri, headers: headers, body: body);
    return encodeRES(res);
  }

  static Future<dynamic> PATCH(
      String url, Map<String, String> headers, dynamic body) async {
    dynamic res = http.patch(url as Uri, headers: headers, body: body);
    return encodeRES(res);
  }

  static Future<dynamic> DELETE(
      String url, Map<String, String> headers, dynamic body) async {
    dynamic res = http.delete(url as Uri, headers: headers, body: body);
    return encodeRES(res);
  }
}
