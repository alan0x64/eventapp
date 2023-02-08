import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:org/models/org.dart';

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
  Position? orgPosition;

  void setOrgLocation(LatLng x) {
    orgLocation = x;
    notifyListeners();
  }

  void setOrgPosition(Position x) {
    orgPosition = x;
    notifyListeners();
  }
}
// Provider.of<T>(context, listen: false);