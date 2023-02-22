import 'package:flutter/material.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/server.dart';
import 'package:http/http.dart' as http;

import '../utilities/shared.dart';

class Event {
  final String id;
  final String orgId;

  final String eventBackgroundPic;
  final String sig;

  final String location;
  final String title;
  final String description;

  final int eventType;
  final int status;

  final String startDateTime;
  final String endDateTime;

  final int minAttendanceTime; //Number
  final int seats;

  final int attenders;
  final int attended;

  final List<dynamic> eventMembers; // See MembersScreen
  final List<dynamic> blackListed; // See BlacklistMember Screen
  final List<dynamic> eventCerts;

  static List<Color> eventStatusColorList = [
    Colors.blue,
    Colors.green,
    Colors.red
  ];
  static List<String> eventStatusList = ['Upcoming', 'Open', 'Passed'];

  static List<String> eventTypeList = ['Conference', 'Seminar'];
  static List<Color> eventTypeColorList = [Colors.blue, Colors.green];

  const Event({
    this.id = "",
    this.orgId = "",
    this.eventBackgroundPic = "",
    this.sig = "",
    this.title = "",
    this.description = "",
    this.location = "",
    this.status = 0,
    this.eventType = 0,
    this.startDateTime = "0000-00-00 00:00:00.00000",
    this.endDateTime = "0000-00-00 00:00:00.00000",
    this.minAttendanceTime = 0,
    this.seats = 0,
    this.attenders = 0,
    this.attended = 0,
    this.eventMembers = const [],
    this.eventCerts = const [],
    this.blackListed = const [],
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
    seats: res['seats'],
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

Future<Response> genUserCert(String userId, String eventId) async {
  Console.log('$devServer/event/certificate/$userId/$eventId');
  return await GET('$devServer/event/certificate/$userId/$eventId', 0, 'AT');
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
Future<Response> updateEvent(String eventId, Map<String, dynamic> data) async {
  return await PATCH('$devServer/event/update/$eventId', 0, 'AT', data);
}

//DELETE
Future<Response> deleteEvent(String eventId) async {
  return await DELETE('$devServer/event/delete/$eventId', 0, 'AT', {});
}

http.MultipartRequest addEventFields(
    {required http.MultipartRequest request,
    required Map<String, dynamic> data}) {
  request.fields['title'] = data['title'];
  request.fields['description'] = data['description'];
  request.fields['seats'] = data['seats'].toString();
  request.fields['status'] = data['status'].toString();
  request.fields['eventType'] = data['eventType'].toString();
  request.fields['minAttendanceTime'] = data['minAttendanceTime'].toString();
  request.fields['startDateTime'] = data['startDateTime'].toString();
  request.fields['endDateTime'] = data['endDateTime'].toString();
  request.fields['location'] = data['location'].toString();

  return request;
}

Future<dynamic> updateEventStatus(BuildContext context,Event eventdata,int status) async {
  return await runFun(
    context,
    () async {
      return await updateEvent(eventdata.id, {
        "title": eventdata.title,
        'startDateTime': eventdata.startDateTime,
        'endDateTime': eventdata.endDateTime,
        "status": status,
        "onlyFields": true
      });
    },
  );
}
