import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/servers.dart';
import 'package:org/utilities/shared.dart';

Future<void> storeTokens(String rt, String at) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  await storage.write(key: "RT", value: rt);
  await storage.write(key: "AT", value: at);
}

void storeToken(String key, String token) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  await storage.write(key: key, value: token);
}

Future<String> getToken(String key) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  return (await storage.read(key: key))!;
}

Future<bool> isTokenExp(String key) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  String? token = await storage.read(key: key);
  if (token == null) return true;
  return Jwt.isExpired(token);
}

Future<bool> renewAT() async {
  Response res = await POST(authServer, 0, 'RT', {});
  if (res.data.isEmpty) return false;
  storeToken('AT', res.data['AT']);
  return true;
}

Future<bool> checkOrRenewTokens() async {
  if (await isTokenExp('RT')) return false;
  if (await isTokenExp('AT')) {
    if (await renewAT() == false) Console.logError("Cannot Renew Token");
  }
  return true;
}
