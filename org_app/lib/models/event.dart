import 'package:org/net/HTTP.dart';
import 'package:org/server.dart';

class Event {
  String eventBackgroundPic;
  String sig;
  String title;
  String description;
  String location;
  int status = 0;
  int eventType = 0;
  DateTime startDateTime;
  DateTime endDateTime;
  int minAttendanceTime;
  int sets;
  int attenders;
  int attended;
  List<String> eventMembers;
  List<String> eventCerts;
  List<String> blackListed;

  Event({
    required this.eventBackgroundPic,
    required this.sig,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
    required this.eventType,
    required this.startDateTime,
    required this.endDateTime,
    required this.minAttendanceTime,
    required this.sets,
    required this.attenders,
    required this.attended,
    required this.eventMembers,
    required this.eventCerts,
    required this.blackListed,
  });
}

Event event(res) {
  return Event(
    eventBackgroundPic: res['eventBackgroundPic'],
    sig: res['sig'],
    title: res['title'],
    description: res['description'],
    location: res['location'],
    status: res['status'],
    eventType: res['eventType'],
    startDateTime: res['startDateTime'],
    endDateTime: res['endDateTime'],
    minAttendanceTime: res['minAttendanceTime'],
    sets: res['sets'],
    attenders: res['Attenders'],
    attended: res['Attended'],
    eventMembers: res['eventMembers'],
    eventCerts: res['eventCerts'],
    blackListed: res['blackListed'],    
  );
}

//GET
Future<Response> getEventInfo(String eventId) async {
  return await GET('$devServer/event/info/$eventId', 0, 'AT');
}

Future<Response> getEventMembers(String eventId) async {
  return await GET('$devServer/event/members/$eventId', 0, 'AT');
}

Future<Response> getBlacklistMembers(String eventId) async {
  return await GET('$devServer/event/blacklist/$eventId', 0, 'AT');
}

//POST
Future<Response> createEvent(Map<String, dynamic> data) async {
  return await POST('$devServer/event/register', 1, 'AT', data);
}

Future<Response> genCerts(String eventId) async {
  return await POST('$devServer/event/cert/$eventId', 0, 'AT', {});
}


//PATCH
Future<Response> updateEvent(String eventId,Map<String, dynamic> data) async {
  return await PATCH('$devServer/event/update/$eventId', 1, 'AT', data);
}

//DELETE
Future<Response> deleteEvent(String eventId) async {
  return await DELETE('$devServer/event/delete/$eventId', 0, 'AT', {});
}