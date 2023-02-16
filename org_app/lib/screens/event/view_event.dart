import 'package:flutter/material.dart';
import 'package:org/models/event.dart';
import 'package:org/models/org.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/screens/event/qr.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/dialog.dart';
import 'package:org/widgets/future_builder.dart';

import 'event_users.dart';

class ViewEvent extends StatefulWidget {
  final String eventId;

  const ViewEvent({super.key, required this.eventId,});

  @override
  State<ViewEvent> createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> {
  Org? orgdata;

  @override
  Widget build(BuildContext context) {
    return BuildFuture(
      callback: () async {
        orgdata = toOrg(await runFun(context, getOrg));
        return await getEventInfo(widget.eventId);
      },
      mapper: (resData) => toEvent(resData.data),
      builder: (data) {
        Event eventdata = data;
        return Scaffold(
          appBar:
              buildAppBar(context, eventdata.title, button: const BackButton()),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Stack(
                children: [
                  buildcoverimage(null, eventdata.eventBackgroundPic),
                  buildEditIcon(Colors.blue,
                      const EdgeInsets.fromLTRB(320, 155, 0, 0), false, (() {
                    // goto(context, EditEvent());
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            goto(
                                context,
                                ViewEventUser(
                                  eventId: eventdata.id,
                                ));
                          },
                          child: const Text("Attenders")),
                      ElevatedButton(
                          onPressed: () {
                            showOnMap(context, eventdata.location);
                          },
                          child: const Text("View Location On Map")),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            goto(
                                context,
                                QRScreen(
                                  eventId: eventdata.id,
                                  eventName: eventdata.title,
                                ));
                          },
                          child: const Text("View QRs")),
                      ElevatedButton(
                          onPressed: () {
                              goto(
                                context,
                                ViewEventUser(
                                  eventId: eventdata.id,
                                  blacklist: true,
                                ));
                          },
                          child: const Text("Blacklisted Users")),
                    ],
                  ),
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
                      xcolor: Event.eventStatusColorList[eventdata.eventType]),
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
                eventdata.seats,
              ),
              const SizedBox(
                height: 30,
              ),
              buildViewInfo("Description", eventdata.description),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: 45,
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
                                "This Will Send Notification To All Users,This Action Cannot Be Undone",
                            quit: false,
                            fun: () async {
                              Navigator.pop(context);
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
              )
            ],
          ),
        );
      },
    );
  }
}
