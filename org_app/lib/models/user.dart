import '../net/HTTP.dart';
import '../server.dart';

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

Future<Response> getUser(String userId) async {
  return await GET('$devServer/user/profile/$userId', 0, 'AT');
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

Future<Response> searchUsers(String eventId, dynamic value,
    {int lnum = 0, int fnum = 0}) async {
  return await POST('$devServer/user/search', 0, 'AT',
      {"eventId": eventId, "fnum": fnum, "lnum": lnum, "fieldValue": value});
}
