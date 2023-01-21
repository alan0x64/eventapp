import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

void storeTokens(String rt, String at) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  await storage.write(key: "RT", value: rt);
  await storage.write(key: "AT", value: at);
}

void storeToken(String key ,String token) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  await storage.write(key: key, value: token);
}

Future<String> getToken(String key) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  return (await storage.read(key: key))!;
}

Future<bool> isTokenExp(String key) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  String token = await storage.read(key: key) as String;
  if (!Jwt.isExpired(token)) return false;
  return true;
}

/*

login
- RT-AT
- Store Them
- home screen

- Before Any REQ
- get AT from storage
- check if AT valid 
  - if no get new token
  - replace the old AT
  - add it to header 

- Before Any REQ
- get RT from storage
- check if RT valid 
  - if no ask the User to Login Again
  - replace the old RT
  


*/
