import 'package:org/net/HTTP.dart';
import 'package:org/servers.dart';

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
    required this.bio,
    required this.orgtype,
    required this.location,
    required this.orgEvents,
  });
}

Org mapOrg(res) {
  return Org(
      orgPic: res.data['orgPic'],
      orgBackgroundPic: res.data['orgBackgroundPic'],
      orgName: res.data['orgName'],
      email: res.data['email'],
      password: res.data['password'],
      phoneNumber: res.data['phoneNumber'],
      bio: res.data['bio'],
      location: res.data['location'],
      orgtype: res.data['orgtype'],
      orgEvents: res.data['orgEvents']);
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
