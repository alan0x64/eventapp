

import '../net/HTTP.dart';
import '../server.dart';

class User {
  String profilePic;
  String fullName;
  String email;
  String password;
  String phoneNumber;
  String dateOfBirth;
  String university;
  String faculty;
  String department;
  String scientificTitle;
  String bio;
  String id;
  List<dynamic> joinedEvents;

  User({
    required this.id,
    required this.profilePic,
    required this.fullName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.university,
    required this.faculty,
    required this.department,
    required this.scientificTitle,
    required this.bio,
    required this.joinedEvents,
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

Future<Response> getUser(String userId) async {
  return await GET('$devServer/user/profile/$userId', 0, 'AT');
}


// PATCH 

Future<Response> checkIn(String eventId,String userId) async {
  return await PATCH('$devServer/event/checkin', 0, 'AT', {
    "userId":userId,
    "eventId":eventId
  });
}

Future<Response> checkOut(String eventId,String userId) async {
  return await PATCH('$devServer/event/checkout', 0, 'AT', {
    "userId":userId,
    "eventId":eventId
  });
}