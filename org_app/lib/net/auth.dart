import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/server.dart';
import 'package:org/utilities/shared.dart';

Future<void> storeTokens(String rt, String at) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  await storage.write(key: "RT", value: rt);
  await storage.write(key: "AT", value: at);
}

Future<void> storeToken(String key, String token) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  await storage.write(key: key, value: token);
}

Future<void> clearTokens() async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  await storage.deleteAll();
}

Future<String> getToken(String key) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  String? token = await storage.read(key: key);
  if (token == null) throw Exception("NULL_TOKEN");
  return (token);
}

Future<bool> isTokenExp(String key) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  String? token = await storage.read(key: key);
  if (token == null) return true;
  return Jwt.isExpired(token);
}

Future<bool> renewAT() async {
  Response res = await POST(authServer, 0, 'RT', {});
  if (res.statusCode == 401) {
    await clearTokens();
    Console.log("Invalid Tokens");
  }
  if (res.data.isEmpty) return false;
  await storeToken('AT', res.data['AT']);
  return true;
}

Future<bool> checkOrRenewTokens() async {
  if (await isTokenExp('RT')) return false;
  if (await isTokenExp('AT')) {
    if (await renewAT() == false) Console.logError("Cannot Renew Token");
  }
  return true;
}
