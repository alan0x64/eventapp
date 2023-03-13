// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher_string.dart';

import '../../models/event.dart';
import '../../models/org.dart';
import '../../models/user.dart';
import '../../net/HTTP.dart';
import '../../utilities/notofocation.dart';
import '../../utilities/shared.dart';
import '../../widgets/dialog.dart';
import '../../widgets/future_builder.dart';
import '../org/view_org.dart';

class ViewEvent extends StatefulWidget {
  final String eventId;
  final String orgId;

  const ViewEvent({
    super.key,
    required this.eventId,
    required this.orgId,
  });

  @override
  State<ViewEvent> createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> {
  Response res = Response();
  bool registred = false;
  Org? orgdata;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: BuildFuture(
        callback: () async {
          registred =
              (await runFun(context, () => joinEvent(widget.eventId, check: 1)))
                  .data['msg'];
          orgdata = toOrg(await runFun(
            context,
            () => getOrg(orgId: widget.orgId),
          ));
          return await getEventInfo(widget.eventId);
        },
        mapper: (resData) => toEvent(resData.data),
        builder: (data) {
          Event eventdata = data;
          return Scaffold(
            appBar: buildAppBar(context, eventdata.title,
                button: const BackButton(),),
            body: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                buildcoverimage(null, eventdata.eventBackgroundPic),
                const SizedBox(
                  height: 24,
                ),
                buildTitle(eventdata.title, orgdata!.orgName),
                const SizedBox(
                  height: 30,
                ),
                const SizedBox(
                  height: 3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                        ),
                        onPressed: () {
                          showOnMap(context, eventdata.location);
                        },
                        child: const Text("View Location On Map")),
                    ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 15, 60, 182)),
                        ),
                        onPressed: () {
                          goto(
                              context,
                              OrgView(
                                orgId: widget.orgId,
                              ));
                        },
                        child: const Text("View Org")),
                    if (eventdata.status == 2)
                      ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 180, 84, 6)),
                          ),
                          onPressed: () async {
                            String cert = (await runFun(
                              context,
                              () async {
                                return await getCertificate(widget.eventId);
                              },
                            ))
                                .data['msg'].toString();

                            if (cert!='0') {
                              launchUrlString(cert,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              snackbar(
                                  context,
                                  "You Did Not Get A Certificate For This Event",
                                  3);
                            }
                          },
                          child: const Text("Cert")),
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
                  height: 25,
                ),
                if (!registred && eventdata.status != 2)
                  Container(
                    height: 45,
                    margin: const EdgeInsets.all(7),
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          res = await runFun(
                            context,
                            () async {
                              return joinEvent(widget.eventId);
                            },
                          );
                          if (res.statusCode == 200) {
                            setState(() {});
                            subscribeToTopic(widget.eventId);
                          }
                          snackbar(context, res.data['msg'], 4);
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 14),
                        )),
                  ),
                if (registred && eventdata.status != 2)
                  Container(
                    height: 45,
                    margin: const EdgeInsets.all(7),
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                        ),
                        onPressed: () async {
                          return showDialog(
                            builder: (context) => CustomDialog(
                              bigText: "Sure Wanna Unreigster?",
                              smallerText:
                                  "Unregistering will disable your ability to check in or check out, and you will need to check in again if you decide to re-register",
                              fun: () async {
                                res = await runFun(
                                  context,
                                  () async {
                                    return quitEvent(widget.eventId);
                                  },
                                );
                                if (res.statusCode == 200) {
                                  setState(() {});
                                  unsubscribeFromTopic(widget.eventId);
                                }
                                snackbar(context, res.data['msg'], 4);
                                Navigator.pop(context);
                                return await Future.value(Response());
                              },
                            ),
                            context: context,
                          );
                        },
                        child: const Text(
                          "Unregister",
                          style: TextStyle(fontSize: 14),
                        )),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
