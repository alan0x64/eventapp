// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';

import '../../models/user.dart';
import '../../utilities/shared.dart';
import '../../widgets/future_builder.dart';

class QRScreen extends StatefulWidget {
  int checkinCheckout = 0;

  QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, "QR Account Info", button: const BackButton()),
      body: BuildFuture(
        callback: () => getUser(),
        mapper: (resData) => toUser(resData.data),
        builder: (data) {
          User userx = data;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  " User Name: ${userx.fullName}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.all(5),
                  child: const Text(
                    'Scan this QR Code to get User Info.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      QrImage(
                        data: userx.id,
                        version: QrVersions.auto,
                        gapless: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
