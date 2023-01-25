

class User {
  String profilePic;
  String fullName;
  String email;
  String password;
  String phoneNumber;
  DateTime dateOfBirth;
  String university;
  String faculty;
  String department;
  String scientificTitle;
  String bio;
  List<String> joinedEvents;

  User({
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

User user(dynamic res) {
  return User(
    profilePic: res['profilePic'],
    fullName: res['fullName'],
    email: res['email'],
    password: res['password'],
    phoneNumber: res['phoneNumber'],
    dateOfBirth: res['date_of_birth'],
    university: res['university'],
    faculty: res['faculty'],
    department: res['department'],
    scientificTitle: res['scientific_title'],
    bio: res['bio'],
    joinedEvents: res['joinedEvents'],
  );
}
