// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:org/models/event.dart';
import 'package:org/models/org.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/screens/event/status%20copy.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/dialog.dart';
import 'package:org/widgets/future_builder.dart';

import '../../utilities/notofocation.dart';
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
                  ElevatedButton(
                      onPressed: () {
                        showOnMap(context, eventdata.location);
                      },
                      child: const Text("View Location On Map")),
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
              if (eventdata.status == 0)
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
                                  "This Will Send Notidy All Users That This Event Started,This Action Cannot Be Undone",
                              quit: false,
                              fun: () async {
                                await notifySubscribers(
                                    eventdata.id, eventdata.id);
                                res = await updateEventStatus(
                                    context, eventdata, 1);
                                snackbar(context, res.data['msg'], 2);
                                Navigator.pop(context);
                                if (res.statusCode == 200) {
                                  setState(() {});
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
                Container(
                  height: 45,
                  width: double.infinity,
                  margin: const EdgeInsets.all(5),
                  child: ElevatedButton(
                      onPressed: () {
                        goto(context, StatusTwo(eventId: eventdata.id,));
                      },
                      child: const Text(
                        "View Status",
                        style: TextStyle(fontSize: 14),
                      )),
                ),
              ElevatedButton(
                  onPressed: () {
                    subscribeToTopic(eventdata.id);
                  },
                  child: const Text("SUb"))
            ],
          ),
        );
      },
    );
  }
}
