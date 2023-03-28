// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:org/models/event.dart';
import 'package:org/models/org.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/screens/event/certs.dart';
import 'package:org/screens/event/scanner.dart';
import 'package:org/utilities/shared.dart';
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
                  height: 24,
                ),
                buildTitle(eventdata.title, orgdata!.orgName),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          goto(
                              context,
                              ViewEventUser(
                                eventId: eventdata.id,
                                registred: true,
                                showControl:
                                    eventdata.status == 2 ? false : true,
                                blacklist: false,
                              ));
                        },
                        child: const Text("Registred Users")),
                    ElevatedButton(
                        onPressed: () {
                          goto(
                              context,
                              ViewEventUser(
                                eventId: eventdata.id,
                                blacklist: true,
                                showControl: false,
                              ));
                        },
                        child: const Text("Blacklisted Users")),
                  ],
                ),
                const SizedBox(
                  height: 3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          showOnMap(context, eventdata.location);
                        },
                        child: const Text("View Location On Map")),
                    if (eventdata.status == 2)
                      ElevatedButton(
                          onPressed: () => goto(
                              context,
                              CertsView(
                                eventId: eventdata.id,
                              )),
                          child: const Text("View Generated Certs")),
                  ],
                ),
                const SizedBox(
                  height: 35,
                ),
                Row(
                  children: [
                    buildViewInfo(
                        "Status", Event.eventStatusList[eventdata.status],
                        xcolor: Event.eventStatusColorList[eventdata.status]),
                    buildViewInfo(
                        "EventType", Event.eventTypeList[eventdata.eventType],
                        xcolor:
                            Event.eventStatusColorList[eventdata.eventType]),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                buildViewInfo(
                  "Start Time",
                  "${eventdata.startDateTime.substring(0, 10)} - ${timeTo12(eventdata.startDateTime)}",
                  xcolor: Colors.green,
                ),
                const SizedBox(
                  height: 30,
                ),
                buildViewInfo(
                  "End Time",
                  "${eventdata.endDateTime.substring(0, 10)} - ${timeTo12(eventdata.endDateTime)}",
                  xcolor: Colors.red,
                ),
                const SizedBox(
                  height: 30,
                ),
                buildViewInfo(
                  "Minimum Attendance Time",
                  "${eventdata.minAttendanceTime} Minutes",
                ),
                const SizedBox(
                  height: 30,
                ),
                buildViewInfo(
                  "Total Number Of Seats",
                  "${eventdata.seats} Seats",
                ),
                if (eventdata.status == 2)
                  const SizedBox(
                    height: 30,
                  ),
                if (eventdata.status == 2)
                  buildViewInfo(
                    "Total Attended",
                    "${eventdata.attended} Individuals",
                  ),
                const SizedBox(
                  height: 30,
                ),
                buildViewInfo("Description", eventdata.description),
                const SizedBox(
                  height: 30,
                ),
                if (eventdata.status == 0)
                  Container(
                    height: 40,
                    width: double.infinity,
                    margin: const EdgeInsets.all(5),
                    child: ElevatedButton(
                        onPressed: () {
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
                        },
                        child: const Text(
                          "Start Event",
                          style: TextStyle(fontSize: 14),
                        )),
                  ),
                if (eventdata.status == 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          child: ElevatedButton(
                              onPressed: () {
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
                                                    eventId: widget.eventId)
                                                    );

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
                              child: const Text(
                                "Scan QRs",
                                style: TextStyle(fontSize: 14),
                              )),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          child: ElevatedButton(
                              onPressed: () async {
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
                              child: const Text(
                                "Finish Event",
                                style: TextStyle(fontSize: 14),
                              )),
                        ),
                      ),
                    ],
                  ),
                Container(
                  height: 40,
                  width: double.infinity,
                  margin: const EdgeInsets.all(5),
                  child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll<Color>(Colors.red),
                      ),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                              bigText: "Sure Wanna Delete Event?",
                              smallerText:
                                  "Please note that this action is irreversible",
                              fun: () async {
                                res = await runFun(
                                    context, () => deleteEvent(widget.eventId));
                                if (res.statusCode == 200) {
                                  moveBack(context, 2);
                                }
                                snackbar(context, res.data['msg'], 3);
                                return res;
                              },
                            );
                          },
                        );
                      },
                      child: const Text("Delete")),
                ),
                if(kDebugMode)
                ElevatedButton(
                    onPressed: () async {
                      res = await updateEventStatus(context, eventdata, 0);
                      snackbar(context, res.data['msg'], 2);
                      setState(() {});
                      return await Future.value();
                    },
                    child: const Text("Reset")),
                if(kDebugMode)
                ElevatedButton(
                    onPressed: () async {
                      notifySubscribers(eventdata.id);
                      return await Future.value();
                    },
                    child: const Text("notify")),
              ],
            ),
          );
        },
      ),
    );
  }
}
