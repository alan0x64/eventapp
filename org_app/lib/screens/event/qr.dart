// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:org/utilities/shared.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../server.dart';

class QRScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  int checkinCheckout = 0;

  QRScreen({super.key, required this.eventId, required this.eventName});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  @override
  Widget build(BuildContext context) {
    String eventId = widget.eventId;
    String url;
    String buttonText;
    String word;

    if (widget.checkinCheckout == 0) {
      url = '$devServer/event/checkin/$eventId';
      buttonText = 'Show Checkout QR';
      word = 'check in';
    } else {
      url = '$devServer/event/checkout/$eventId';
      buttonText = 'Show Checkin QR';
      word = 'check out';
    }

    return Scaffold(
      appBar:buildAppBar(context, "QR",button: const BackButton()),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.eventName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.all(5),
              child: Text(
                'Scan this QR Code to $word and confirm your attendance for the event.',
                style: const TextStyle(
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
                    data: url,
                    version: QrVersions.auto,
                    gapless: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (widget.checkinCheckout == 0) {
                  widget.checkinCheckout = 1;
                } else {
                  widget.checkinCheckout = 0;
                }
                setState(() {});
              },
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
