import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../models/org.dart';

class LogedInData extends ChangeNotifier {
  Org? data;

  void setLogedInData(Org data) {
    data = data;
    notifyListeners();
  }

  Org getLogedInData() {
    return data as Org;
  }
}

class LocationProvider extends ChangeNotifier {
  LatLng? orgLocation;
  LatLng? eventLocation;

  operator [](int index) {
    if (index == 0) {
      return orgLocation;
    }

    if (index == 1) {
      return eventLocation;
    }
  }

  void setOrgLocation(LatLng x) {
    orgLocation = x;
    notifyListeners();
  }

  void setEventLocation(LatLng x) {
    eventLocation = x;
    notifyListeners();
  }
}

class ObjImageProvider extends ChangeNotifier {
  XFile? orgPic;
  XFile? orgBackgroundPic;
  XFile? eventPic;
  XFile? eventSig;

  operator [](int index) {
    if (index == 0) {
      return orgPic;
    }

    if (index == 1) {
      return orgBackgroundPic;
    }

     if (index == 3) {
      return eventPic;
    }

    if (index == 4) {
      return eventSig;
    }
  }

  void setEventPic(XFile? eventpic) {
    eventPic = eventpic;
    notifyListeners();
  }

  void setEventSig(XFile? eventsig) {
    eventSig = eventsig;
    notifyListeners();
  }
}

// Provider.of<T>(context, listen: false);