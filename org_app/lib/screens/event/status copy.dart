// ignore: file_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:org/models/event.dart';
import 'package:org/models/user.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/future_builder.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:theme_provider/theme_provider.dart';

import 'event_users.dart';

class StatusTwo extends StatefulWidget {
  String eventId;
  List<String> scanStatus = ['Check In', 'Check Out'];
  bool update = false;

  StatusTwo({Key? key, required this.eventId}) : super(key: key);

  @override
  State<StatusTwo> createState() => _StatusTwoState();
}

class _StatusTwoState extends State<StatusTwo> {
  late Event eventdata;
  Color boxColor = const Color.fromARGB(255, 44, 42, 42);
  Color textColor = const Color.fromARGB(255, 226, 221, 221);
  int scan = 0;
  Response res = Response();
  Barcode? result;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;


  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    String scanStatus = widget.scanStatus[scan];
    bool isDarkTheme =
        ThemeProvider.themeOf(context).id == "default_dark_theme";
    boxColor = isDarkTheme
        ? const Color.fromARGB(255, 226, 225, 225)
        : const Color.fromARGB(255, 44, 42, 42);
    textColor = isDarkTheme
        ? const Color.fromARGB(255, 19, 18, 18)
        : const Color.fromARGB(255, 226, 221, 221);

    return BuildFuture(
      callback: () async => await getEventInfo(widget.eventId),
      mapper: (resData) => toEvent(resData.data),
      builder: (data) {
        eventdata = data;
        int attenders = eventdata.attenders;

        return Scaffold(
          body: Stack(
            children: [
              QRView(
                key: qrKey,
                onQRViewCreated: (QRViewController controller) {
                  widget.update = true;
                  controller.resumeCamera();
                  controller.scannedDataStream.listen((Barcode barcode) async {
                    res = await runFun(
                      context,
                      () async {
                        return await checkIn(
                            eventdata.id, barcode.code as String);
                      },
                    );
                  });
                  if (res.statusCode == 200 && widget.update) {
                    widget.update = false;
                    setState(() {});
                    snackbar(context, res.data['msg'], 2);
                  }
                  Console.log(res.data);
                },
                overlay: QrScannerOverlayShape(
                    cutOutSize: MediaQuery.of(context).size.width * 0.8,
                    borderWidth: 10,
                    borderLength: 20,
                    borderRadius: 10,
                    borderColor: const Color.fromARGB(255, 51, 226, 57)),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Attenders: $attenders",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Scan Status: ",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                scanStatus,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () {
                                controller!.toggleFlash();
                              },
                              icon: Icon(
                                Icons.flash_off,
                                color: textColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                controller!.flipCamera();
                              },
                              icon: Icon(
                                Icons.switch_camera,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 187, 10, 69),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              onPressed: () {
                                goto(
                                    context,
                                    ViewEventUser(
                                      eventId: eventdata.id,
                                    ));
                              },
                              child: const Text("See Attenders")),
                          ElevatedButton(
                            onPressed: () {
                              scan == 0 ? scan = 1 : scan = 0;
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 168, 150, 44),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            child: const Text("Toggle Scan Status"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
