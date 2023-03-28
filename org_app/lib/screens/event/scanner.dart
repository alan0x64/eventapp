// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:org/models/event.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/screens/users/user_view.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/future_builder.dart';
import 'package:org/widgets/indicator.dart';
import 'package:org/widgets/message_dialog.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:theme_provider/theme_provider.dart';

import '../../models/user.dart';
import 'event_users.dart';

class Status extends StatefulWidget {
  final String eventId;
  final List<String> scanStatus = ['Check In', 'Check Out'];
  final int scanMode;

  Status({Key? key, required this.eventId,required this.scanMode}) : super(key: key);

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  Response res = Response();
  late Event eventdata;
  Color boxColor = const Color.fromARGB(255, 44, 42, 42);
  Color textColor = const Color.fromARGB(255, 226, 221, 221);
  int scan = 0;
  String? userId;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  Future<dynamic> getId() async {
    while (userId == null) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    return userId;
  }

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
    bool failed = false;
    String st = widget.scanStatus[widget.scanMode];
    if (ThemeProvider.themeOf(context).id == "default_dark_theme") {
      boxColor = const Color.fromARGB(255, 226, 225, 225);
      textColor = const Color.fromARGB(255, 19, 18, 18);
    }
    return BuildFuture(
      callback: () async => await getEventInfo(widget.eventId),
      mapper: (resData) => toEvent(resData.data),
      builder: (data) {
        eventdata = data;
        int attenders = eventdata.attenders;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Scan QRs'),
            actions: const [
              // IconButton(
              //   icon: const Icon(Icons.flash_off),
              //   onPressed: () =>
              //       controller != null ? controller!.toggleFlash() : null,
              // ),
              // IconButton(
              //     icon: const Icon(Icons.camera),
              //     onPressed: () =>
              //         controller != null ? controller!.flipCamera() : null),
            ],
          ),
          body: Stack(children: [
            Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: boxColor,
                          width: 1,
                        ),
                      ),
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: (QRViewController controller) {
                          controller.resumeCamera();
                          controller.scannedDataStream
                              .listen((Barcode barcode) {
                            userId = barcode.code;
                          });
                        },
                      )),
                ),
                Expanded(
                  flex: 1,
                  child: BuildFuture(
                    callback: () => getAttenders(widget.eventId),
                    mapper: (resdata) {
                      return mapObjs(resdata.data['members'], toUser);
                    },
                    builder: (userdata) {
                      return Column(
                        children: [
                          const Text(
                            'Attenders',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: userdata.length,
                              itemBuilder: (BuildContext context, int index) {
                                User user = userdata[index];
                                return InkWell(
                                  onTap: () {
                                    goto(
                                        context,
                                        UserProfilePage(
                                          userId: user.id,
                                          eventId: widget.eventId,
                                          blacklist: eventdata.blackListed
                                              .contains(user.id),
                                        ));
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(5),
                                    width: 160.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30.0,
                                          backgroundImage:
                                              NetworkImage(user.profilePic),
                                        ),
                                        const SizedBox(height: 5.0),
                                        Text(
                                          user.fullName,
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(15),
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
                                st,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 168, 105, 10),
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 59, 7, 155),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              onPressed: () {
                                goto(
                                    context,
                                    ViewEventUser(
                                      attended:true,
                                      eventId: eventdata.id,
                                    ));
                              },
                              child: const Text("See Attended")),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Expanded(
                  flex: 4,
                  child: FutureBuilder(
                    future: QRCheckin(
                      context,
                      widget.eventId,
                      widget.scanMode,
                      () async {
                        return await getId();
                      },
                    ),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        if (Response.errorStatus
                            .contains(snapshot.data.statusCode)) {
                          failed = true;
                        }
                      } else if (snapshot.hasError) {
                        failed = true;
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Center(
                          child: MessageDialog(
                        showButtonThree: snapshot.hasData ? true : false,
                        cupertino: true,
                        message:
                            snapshot.data.data['msg'] ?? "Somthing Went Wrong",
                        buttonOneText: "Scan Again",
                        buttonTwoText: "Go Back To Event",
                        buttonThreeText: 'View Scanned User',
                        buttonOne: () {
                          userId = null;
                          setState(() {});
                        },
                        buttonTwo: () {
                          moveBack(context, 1);
                        },
                        buttonThree: () {
                          goto(
                              context,
                              UserProfilePage(
                                userId: userId as String,
                                blacklist: false,
                                eventId: widget.eventId,
                              ));
                        },
                        icon: Indicator(failed: failed),
                      ));
                    },
                  ),
                ),
              ],
            ),
          ]),
        );
      },
    );
  }
}
