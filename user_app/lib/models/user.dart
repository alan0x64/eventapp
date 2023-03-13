import '../net/HTTP.dart';
import '../server.dart';
import 'package:http/http.dart' as http;

class User {
  final String profilePic;
  final String fullName;
  final String email;
  final String password;
  final String phoneNumber;
  final String dateOfBirth;
  final String university;
  final String faculty;
  final String department;
  final String scientificTitle;
  final String bio;
  final String id;
  final List<dynamic> joinedEvents;

  static List<String> userSearchFields = [
    'FullName',
    'Email',
    'University',
    'Faculty',
    'Department',
    'Scientific Title'
  ];
  const User({
    this.id = "",
    this.profilePic = "",
    this.fullName = "",
    this.email = "",
    this.password = "",
    this.phoneNumber = "",
    this.dateOfBirth = "",
    this.university = "",
    this.faculty = "",
    this.department = "",
    this.scientificTitle = "",
    this.bio = "",
    this.joinedEvents = const [],
  });
}

User toUser(dynamic res) {
  return User(
    id: res['_id'],
    profilePic: res['profilePic']['url'],
    fullName: res['fullName'],
    email: res['email'],
    password: res['password'],
    phoneNumber: res['phoneNumber'].toString(),
    dateOfBirth: res['date_of_birth'],
    university: res['university'],
    faculty: res['faculty'],
    department: res['department'],
    scientificTitle: res['scientific_title'],
    bio: res['bio'],
    joinedEvents: res['joinedEvents'],
  );
}

http.MultipartRequest addUserFields(
    {required http.MultipartRequest request,
    required Map<String, dynamic> data}) {
  request.fields['fullName'] = data['fullName'];
  request.fields['email'] = data['email'];
  request.fields['phoneNumber'] =data['phoneNumber'];
  request.fields['date_of_birth'] = data['date_of_birth'].toString();
  request.fields['bio'] = data['bio'];
  request.fields['department'] = data['department'];
  request.fields['faculty'] = data['faculty'];
  request.fields['scientific_title'] = data['scientific_title'];
  request.fields['university'] = data['university'];
  
  if (data['password'] != null) {
    request.fields['password'] = data['password'];
  }

  return request;
}

Map<String, dynamic> userToMap(User user) {
  return {
    'fullName': user.fullName,
    'email': user.email,
    'password': user.password,
    'phoneNumber': user.phoneNumber,
    'dateOfBirth': user.dateOfBirth,
    'university': user.university,
    'faculty': user.faculty,
    'department': user.department,
    'scientificTitle': user.scientificTitle,
    'bio': user.bio,
  };
}

Future<Response> getUser() async {
  return await GET('$devServer/user/profile', 0, 'AT');
}

Future<Response> getLogedInUser() async {
  return await GET('$devServer/user/profile', 0, 'AT');
}

Future<Response> getCertificate(String eventId) async {
  return await GET('$devServer/user/cert/$eventId', 0, 'AT');
}

Future<Response> getJoinedEvents() async {
  return await GET('$devServer/user/events', 0, 'AT');
}

// PATCH

Future<Response> checkIn(String eventId, String userId) async {
  return await PATCH('$devServer/event/checkin', 0, 'AT',
      {"userId": userId, "eventId": eventId});
}

Future<Response> checkOut(String eventId, String userId) async {
  return await PATCH('$devServer/event/checkout', 0, 'AT',
      {"userId": userId, "eventId": eventId});
}

Future<Response> updateUser(dynamic data) async {
  return await PATCH('$devServer/user/update', 0, 'AT',data);
}

Future<Response> searchUsers(String eventId, dynamic value,
    {int lnum = 0, int fnum = 0}) async {
  return await POST('$devServer/user/search', 0, 'AT',
      {"eventId": eventId, "fnum": fnum, "lnum": lnum, "fieldValue": value});
}

//-------------------
// POST
Future<Response> login(Map<String, dynamic> data) async {
  return await POST('$devServer/user/login', 0, '0', data);
}

Future<Response> logout() async {
  return await POST('$devServer/user/logout', 0, 'RT', {});
}

// PATCH
Future<Response> updateProfileNoImages(
  Map<String, dynamic> data,
) async {
  return await PUT("$devServer/user/update/x", 0, "AT", data);
}

Future<Response> joinEvent(String eventId, {int check = 0}) async {
  return await PATCH(
      '$devServer/user/join/$eventId', 0, 'AT', {'check': check});
}

// PUT
Future<Response> updatePassword(Map<String, dynamic> data) async {
  return await PUT('$devServer/user/updatepassword', 0, 'AT', data);
}

// DELETE
Future<Response> deleteAccount() async {
  return await DELETE('$devServer/user/delete', 0, 'AT', {});
}

Future<Response> quitEvent(String eventId) async {
  return await DELETE('$devServer/user/quit/$eventId', 0, 'AT', {});
}
