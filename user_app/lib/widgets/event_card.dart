import 'package:flutter/material.dart';

import '../models/event.dart';
import '../screens/event/view_event.dart';
import '../utilities/shared.dart';

class EventCard extends StatefulWidget {
  final Event eventx;
  const EventCard({super.key, required this.eventx});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    String start = widget.eventx.startDateTime.toString().substring(0, 10);
    String end = widget.eventx.endDateTime.toString().substring(0, 10);

    String seats = (widget.eventx.seats - widget.eventx.attenders).toString();
    String type = Event.eventTypeList[widget.eventx.eventType];
    String status = Event.eventStatusList[widget.eventx.status];
    Color statusColor = Event.eventStatusColorList[widget.eventx.status];
    Color typeColor = Event.eventTypeColorList[widget.eventx.eventType];

    Color seatsColor = widget.eventx.seats <= 5 ? Colors.red : Colors.green;
    return InkWell(
      onTap: () {
        goto(
          context,
          ViewEvent(
            eventId: widget.eventx.id,
            orgId: widget.eventx.orgId,
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
              height: 130,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                image: DecorationImage(
                  image: NetworkImage(widget.eventx.eventBackgroundPic),
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
                        widget.eventx.title,
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
                              style: TextStyle(
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
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (widget.eventx.status == 1)
                            const SizedBox(width: 5),
                          if (widget.eventx.status == 1)
                            Container(
                              padding: const EdgeInsets.all(4),
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
                                style: TextStyle(
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
  }
}
