// ignore_for_file: use_build_context_synchronously

import 'package:EventLink/widgets/button.dart';
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
            appBar: buildAppBar(
              context,
              eventdata.title,
              button: const BackButton(),
            ),
            body: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                buildcoverimage(null, eventdata.eventBackgroundPic),
                const SizedBox(
                  height: 15,
                ),
                buildTitle(eventdata.title, orgdata!.orgName,context),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Button(
                        text: "View Location On Map",
                        cb: () {
                          showOnMap(context, eventdata.location);
                        },
                        color: Colors.green),
                    Button(
                        text: "View Org",
                        cb: () {
                          goto(
                              context,
                              OrgView(
                                orgId: widget.orgId,
                              ));
                        },
                        color: const Color.fromARGB(255, 64, 106, 223)),
                  ],
                ),
                 if (eventdata.status == 2)
                 const SizedBox(
                  height: 10,
                ),
                 if (eventdata.status == 2)
                    Button(text: "Cert", cb: ()async {
                      String cert = (await runFun(
                              context,
                              () async {
                                return await getCertificate(widget.eventId);
                              },
                            ))
                                .data['msg']
                                .toString();

                            if (cert != '0') {
                              launchUrlString(cert,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              snackbar(
                                  context,
                                  "You Did Not Get A Certificate For This Event",
                                  3);
                            }
                    }, color: const Color.fromARGB(255, 144, 69, 8)),
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
                  height: 20,
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
                        height: 20,
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
                        height: 20,
                      ),
                      buildViewInfo(
                        titleicon: Icons.timer,
                        context: context,
                        "Minimum Attendance",
                        "${eventdata.minAttendanceTime} Minute",
                      ),
                      const SizedBox(
                        height: 20,
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
                              height: 20,
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
                        height: 20,
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
                if (!registred && eventdata.status != 2)
                  Button(text: "Register", cb: ()  async{
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
                  
                },),
                if (registred && eventdata.status != 2)
                Button(text: "Unregister", cb:() async {
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
                },color: Colors.red),
              ],
            ),
          );
        },
      ),
    );
  }
}
