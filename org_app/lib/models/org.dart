import 'package:org/net/HTTP.dart';
import 'package:org/server.dart';
import 'package:http/http.dart' as http;

class Org {
  final String orgPic;
  final String orgBackgroundPic;
  final String orgName;
  final String email;
  final String password;
  final int phoneNumber;
  final String website;
  final String socialMedia;
  final String bio;
  final int orgtype;
  final String location;
  final List<dynamic> orgEvents;

  const Org({
    this.orgPic = "",
    this.orgBackgroundPic = "",
    this.orgName = "",
    this.email = "",
    this.password = "",
    this.phoneNumber = 0,
    this.bio = "",
    this.website="",
    this.socialMedia="",
    this.orgtype = 0,
    this.location = "0.0,0.0",
    this.orgEvents = const [],
  });
}

Org toOrg(res) {
  return Org(
      orgPic: res.data['orgPic']['url'],
      orgBackgroundPic: res.data['orgBackgroundPic']['url'],
      orgName: res.data['orgName'],
      email: res.data['email'],
      password: res.data['password'],
      phoneNumber: res.data['phoneNumber'],
      bio: res.data['bio'],
      website: res.data['website'],
      socialMedia: res.data['socialMedia'],
      location: res.data['location'],
      orgtype: res.data['org_type'],
      orgEvents: res.data['orgEvents']);
}

// GET

Future<Response> isServerUp() async {
  return await GET('$devServer/test', 0, '0');
}

Future<Response> getOrg() async {
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

Future<Response> blockUser(String userId, String eventId) async {
  return await POST('$devServer/org/$userId/$eventId', 0, 'AT', {});
}

// PATCH
Future<Response> updateProfileNoImages(
  Map<String, dynamic> data,
) async {
  return await PUT("$devServer/org/update/x", 0, "AT", data);
}

// PUT
Future<Response> updatePassword(Map<String, dynamic> data) async {
  return await PUT('$devServer/org/updatepassword', 0, 'AT', data);
}

// DELETE
Future<Response> deleteAccount() async {
  return await DELETE('$devServer/org/delete', 0, 'AT', {});
}

Future<Response> unblockUser(String userId, String eventId) async {
  return await DELETE('$devServer/org/$userId/$eventId', 0, 'AT', {});
}


http.MultipartRequest addOrgFields(
    {
      required http.MultipartRequest request,
      required Map<String, dynamic> data
    }) {
    request.fields['orgName'] = data['orgName'];
    request.fields['email'] = data['email'];
    request.fields['phoneNumber'] = data['phoneNumber'].toString();
    request.fields['location'] = data['location'];
    request.fields['bio'] = data['bio'];
    request.fields['website'] = data['website'];
    request.fields['socialMedia'] = data['socialMedia'];
    request.fields['location'] = data['location'];
    request.fields['org_type'] = data['org_type'].toString();

    if (data['password'] != null) {
      request.fields['password'] = data['password'];
    }

  return request;
}
