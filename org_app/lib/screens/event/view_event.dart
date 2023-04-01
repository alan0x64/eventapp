// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:org/models/event.dart';
import 'package:org/models/org.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/screens/event/certs.dart';
import 'package:org/screens/event/scanner.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/button.dart';
import 'package:org/widgets/dialog.dart';
import 'package:org/widgets/future_builder.dart';
import 'package:org/widgets/message_dialog.dart';

import '../../models/cert.dart';
import '../../utilities/notofocation.dart';
import 'edit_event.dart';
import 'event_users.dart';

class ViewEvent extends StatefulWidget {
  final String eventId;

  const ViewEvent({
    super.key,
    this.eventId = "",
  });

  @override
  State<ViewEvent> createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> {
  Response res = Response();
  Org? orgdata;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: BuildFuture(
        callback: () async {
          orgdata = toOrg(await runFun(context, getOrg));
          return await getEventInfo(widget.eventId);
        },
        mapper: (resData) => toEvent(resData.data),
        builder: (data) {
          Event eventdata = data;
          return Scaffold(
            appBar: buildAppBar(context, eventdata.title,
                button: const BackButton()),
            body: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Stack(
                  children: [
                    buildcoverimage(null, eventdata.eventBackgroundPic),
                    if (eventdata.status != 2)
                      buildEditIcon(
                          Colors.blue,
                          const EdgeInsets.fromLTRB(320, 155, 0, 0),
                          false, (() {
                        goto(
                            context,
                            EditEvent(
                              eventId: eventdata.id,
                            ));
                      })),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                buildTitle(eventdata.title, orgdata!.orgName, context),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Button(
                      color: Colors.pinkAccent,
                      text: "Registred Users",
                      cb: ()async {
                        goto(
                            context,
                            ViewEventUser(
                              eventId: eventdata.id,
                              registred: true,
                              showControl: eventdata.status == 2 ? false : true,
                              blacklist: false,
                            ));
                      },
                    ),
                    Button(
                      color: const Color.fromARGB(255, 198, 220, 34),
                      text: "Blacklisted Users",
                      cb: () async{
                        goto(
                            context,
                            ViewEventUser(
                              eventId: eventdata.id,
                              blacklist: true,
                              showControl: false,
                            ));
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 3,
                ),
                Button(
                  color: const Color.fromARGB(255, 45, 211, 197),
                  text: "View Location On Map",
                  cb: ()async {
                    showOnMap(context, eventdata.location);
                  },
                ),
                if (eventdata.status == 2)
                  Button(
                    text: "View Generated Certs",
                    cb: () async{
                      goto(
                          context,
                          CertsView(
                            eventId: eventdata.id,
                          ));
                    },
                  ),
                const SizedBox(
                  height: 13,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildViewInfo(
                        icon: Event.eventStatusIconsList[eventdata.status],
                        context: context,
                        "Status",
                        Event.eventStatusList[eventdata.status],
                        xcolor: Event.eventStatusColorList[eventdata.status]),
                    buildViewInfo(
                        icon: Event.eventTypeIconsList[eventdata.eventType],
                        context: context,
                        "EventType",
                        Event.eventTypeList[eventdata.eventType],
                        xcolor:
                            Event.eventStatusColorList[eventdata.eventType]),
                  ],
                ),
                const SizedBox(
                  height: 13,
                ),
                Container(
                  margin: const EdgeInsets.all(5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildViewInfo(
                        icon: Icons.start,
                        context: context,
                        "Start Time",
                        "${eventdata.startDateTime.substring(0, 10)} - ${timeTo12(eventdata.startDateTime)}",
                        xcolor: Colors.green,
                      ),
                      const SizedBox(
                        height: 13,
                      ),
                      buildViewInfo(
                        icon: Icons.timelapse,
                        context: context,
                        "End Time",
                        "${eventdata.endDateTime.substring(0, 10)} - ${timeTo12(eventdata.endDateTime)}",
                        xcolor: Colors.red,
                        // bgColor: ThemeProvider.themeOf(context).;
                      ),
                      const SizedBox(
                        height: 13,
                      ),
                      buildViewInfo(
                        titleicon: Icons.timer,
                        context: context,
                        "Minimum Attendance",
                        "${eventdata.minAttendanceTime} Minute",
                      ),
                      const SizedBox(
                        height: 13,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          buildViewInfo(
                            titleicon: Icons.chair_alt_outlined,
                            context: context,
                            "Total Seats",
                            "${eventdata.seats} Seats",
                          ),
                          if (eventdata.status == 2)
                            const SizedBox(
                              height: 13,
                            ),
                          if (eventdata.status == 2)
                            buildViewInfo(
                              titleicon: Icons.person,
                              context: context,
                              "Attended",
                              "${eventdata.attended} Individuals",
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 13,
                      ),
                      buildViewInfo(
                          titleicon: Icons.description,
                          context: context,
                          "Description",
                          eventdata.description),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (eventdata.status == 0)
                Button(text:"Start Event" ,color: Colors.lightBlue, cb: ()async {
                  showDialog(
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                              bigText: "Are You Sure Wanna Start The Event ?",
                              smallerText:
                                  "This action will notify all users that the event has started. Please note that changes to the event will be limited and irreversible",
                              quit: false,
                              fun: () async {
                                Console.log(
                                    getTimeInMin(eventdata.startDateTime));
                                if (getTimeInMin(eventdata.endDateTime) >
                                    getTimeInMin(eventdata.startDateTime)) {
                                  res = await updateEventStatus(
                                      context, eventdata, 2);
                                }

                                res = await updateEventStatus(
                                    context, eventdata, 1);

                                if (res.statusCode == 200) {
                                  await notifySubscribers(eventdata.id);
                                  Navigator.pop(context);
                                  setState(() {});
                                  snackbar(context,
                                      "Event Started And Users Notified", 4);
                                }

                                return await Future.value(Response());
                              },
                            );
                          },
                        );
                  
                },),
                if (eventdata.status == 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Button(
                          cb: () async{
                             showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Stack(
                                      children: [
                                        ModalBarrier(
                                            dismissible: false,
                                            color:
                                                Colors.black.withOpacity(0.5)),
                                        MessageDialog(
                                          showButtonThree: true,
                                          cupertino: true,
                                          message: "QR Scan Mode",
                                          buttonOneText: "CheckIn Mode",
                                          buttonTwoText: "CheckOut Mode",
                                          buttonThreeText: 'Cancel',
                                          buttonOne: () {
                                            moveBack(context, 1);

                                            goto(
                                                context,
                                                Status(
                                                    scanMode: 0,
                                                    eventId: widget.eventId));
                                          },
                                          buttonTwo: () {
                                            moveBack(context, 1);
                                            goto(
                                                context,
                                                Status(
                                                    scanMode: 1,
                                                    eventId: widget.eventId));
                                          },
                                          buttonThree: () {
                                            moveBack(context, 1);
                                          },
                                          icon: const Icon(Icons.qr_code),
                                        )
                                      ],
                                    );
                                  },
                                );
                          },
                          text:"Scan QRs" ,
                          color: const Color.fromARGB(255, 31, 136, 189),
                        ) 
                      ),
                      Expanded(
                        flex: 1,
                        child: Button(
                          color: const Color.fromARGB(255, 180, 26, 26),
                          text: "Finish Event",
                          cb: () {
                             return showDialog(
                                builder: (context) => CustomDialog(
                                  bigText: "Sure Wanna End Event?",
                                  smallerText:
                                      "Certificates will be produced for any user whose attendance time exceeds the minimum attendance threshold. Please note that this action is irreversible",
                                  fun: () async {
                                    await updateEventStatus(
                                        context, eventdata, 2);
                                    res = await runFun(
                                      context,
                                      () async =>
                                          await genCerts(eventdata.id),
                                    );
                                    await notifySubscribers(eventdata.id);

                                    Navigator.pop(context);
                                    if (res.statusCode == 200) {
                                      setState(() {});
                                    }
                                    snackbar(context, res.data['msg'], 4);
                                    return await Future.value(Response());
                                  },
                                ),
                                context: context,
                              );
                          },
                        )
                      ),
                    ],
                  ),
                if (eventdata.status != 1)
                Button(text: "Delete", color: Colors.red,cb: ()async {
                  showDialog(
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                              bigText: "Sure Wanna Delete Event?",
                              smallerText:
                                  "Please note that this action is irreversible",
                              fun: () async {
                                res = await runFun(context,
                                    () => deleteEvent(widget.eventId));
                                if (res.statusCode == 200) {
                                  moveBack(context, 2);
                                }
                                snackbar(context, res.data['msg'], 3);
                                return res;
                              },
                            );
                            });
                },),

                if (kDebugMode)
                  ElevatedButton(
                      onPressed: () async {
                        res = await updateEventStatus(context, eventdata, 0);
                        snackbar(context, res.data['msg'], 2);
                        setState(() {});
                        return await Future.value();
                      },
                      child: const Text("Reset")),
              ],
            ),
          );
        },
      ),
    );
  }
}
