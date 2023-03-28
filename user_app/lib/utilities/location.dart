// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/dialog.dart';

void enableLocationService(BuildContext context) async {
  LocationPermission per = await Geolocator.checkPermission();
  if (per == LocationPermission.denied ||
      per == LocationPermission.deniedForever ||
      await Geolocator.getLocationAccuracy() == LocationAccuracy.reduced) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          hideCancelButton: true,
          bc: Colors.red,
          quit: false,
          bigText: "Location Access Required!",
          smallerText: "To use this app, please allow access to your location",
          fun: () {
           exit(0);
          },
        );
      },
    );
    Geolocator.openAppSettings();
  } else if (!await Geolocator.isLocationServiceEnabled()) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          hideCancelButton: true,
          bc: Colors.red,
          quit: false,
          bigText: "Location Services Is Disabled!",
          smallerText:
              "To use this app, you need to enable location services on your device",
          fun: () {
            exit(0);
          },
        );
      },
    );

    Geolocator.openLocationSettings();
  }
}

Future<Position> userLocation() async {
  return await Geolocator.getCurrentPosition();
}
