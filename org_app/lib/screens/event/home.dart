// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:org/models/event.dart';
import 'package:org/models/org.dart';
import 'package:org/screens/event/view_event.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/future_builder.dart';
import 'package:org/widgets/screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  LatLng x = LatLng(0, 0);
  List<dynamic>? events;
  @override
  Widget build(BuildContext context) {
    try {
      return Screen(
          ab: buildAppBar(context, "Your Organization Events"),
          builder: (x) {
            return BuildFuture(
              callback: getOrgEvents,
              mapper: (resdata) => mapObjs(resdata.data['events'], toEvent),
              builder: (data) {
                events = data;
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: events?.length,
                  itemBuilder: (context, index) {
                    Event eventx = events![index];
                    String start = eventx
                        .startDateTime
                        .toString()
                        .substring(0, 10);
                    String end =
                        eventx.endDateTime.toString().substring(0, 10);

                    String seats = (eventx.seats - eventx.attenders).toString();
                    String type = Event.eventTypeList[eventx.eventType];
                    String status =
                        Event.eventStatusList[eventx.status];
                    Color statusColor =
                        Event.eventStatusColorList[eventx.status];
                    Color typeColor =
                        Event.eventTypeColorList[eventx.eventType];

                    Color seatsColor =
                        eventx.seats <= 5 ? Colors.red : Colors.green;

                    return InkWell(
                        onTap: () {
                          goto(
                              context,
                              ViewEvent(
                                eventId: eventx.id,
                              ));
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 217, 214, 214),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 10.0,
                                offset: Offset(0.0, 4.0),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          eventx.eventBackgroundPic),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        eventx.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: typeColor,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              type,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: statusColor,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              status,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if(eventx.seats==1)
                                          const SizedBox(width: 10),
                                          if(eventx.seats==1)
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: seatsColor,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              seats,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '$start - $end',
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ));
                  },
                );
              },
            );
          });
    } catch (e) {
      Console.log(e);
    }
    return const Text("data");
  }
}
