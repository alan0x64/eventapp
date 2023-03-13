
import '../net/HTTP.dart';
import '../server.dart';
import 'event.dart';
import 'org.dart';
import 'user.dart';

class Cert {
  int checkInTime;
  int checkOutTime;
  int attendedMins;
  bool allowCert;
  String cert;
  String userId;
  String eventId;
  String orgId;
  User user;
  Event event;
  Org org;


  Cert({
    this.checkInTime = 0,
    this.checkOutTime = 0,
    this.allowCert = false,
    this.attendedMins = 0,
    this.cert = "",
    this.userId = "",
    this.eventId = "",
    this.orgId = "",
    this.user= const User(),
    this.event= const Event(),
    this.org= const Org()
  });
}

Cert toCert(Map<String, dynamic> res) {
  var data = res;
  return Cert(
    checkInTime: data['checkInTime'],
    checkOutTime: data['checkOutTime'],
    allowCert: data['allowCert'],
    attendedMins: data['attendedMins'],
    cert: data['cert']['url'],
    eventId: data['eventId'].runtimeType==Map?data['eventId']['_id']:data['eventId'],
    orgId: data['orgId']??data['orgId']['_id'],
    userId: data['userId'] is Map?data['userId']['_id']:data['userId'],
    user: data['userId'] is Map? toUser(data['userId']):const User(),
    event:data['eventId'] is Map? toEvent(data['eventId']):const Event(),
    org: data['orgId'] is Map ? toOrg(data['orgId']):const Org(),
  );
}

Future<Response> genUserCert(String userId, String eventId) async {
  return await GET('$devServer/event/certificate/$userId/$eventId', 0, 'AT');
}

Future<Response> genCerts(String eventId) async {
  return await GET('$devServer/event/certificate/$eventId', 0, 'AT');
}

Future<Response> getCerts(String eventId) async {
  return await GET('$devServer/event/certs/$eventId', 0, 'AT');
}
