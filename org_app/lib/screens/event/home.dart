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
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: events?.length,
                  itemBuilder: (context, index) {
                    Event eventx = events![index];
                    String start =
                        eventx.startDateTime.toString().substring(0, 10);
                    String end = eventx.endDateTime.toString().substring(0, 10);

                    String seats = (eventx.seats - eventx.attenders).toString();
                    String type = Event.eventTypeList[eventx.eventType];
                    String status = Event.eventStatusList[eventx.status];
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
          ),
        );
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                image: DecorationImage(
                  image: NetworkImage(eventx.eventBackgroundPic),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        eventx.title,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: typeColor,
                                width: 1.0,
                              ),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              type,
                              style:  TextStyle(
                                fontSize: 12,
                                color: typeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: statusColor,
                                width: 1.0,
                              ),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              status,
                              style:  TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (eventx.status == 1)
                            const SizedBox(width: 5),
                          if (eventx.status == 1)
                            Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: seatsColor,
                                width: 1.0,
                              ),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              seats,
                              style:  TextStyle(
                                fontSize: 12,
                                color: seatsColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '$start - $end',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
