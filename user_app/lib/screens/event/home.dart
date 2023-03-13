// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../models/event.dart';
import '../../models/user.dart';
import '../../utilities/shared.dart';
import '../../widgets/event_card.dart';
import '../../widgets/future_builder.dart';
import '../../widgets/screen.dart';
import 'event_search.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.joinView = false});

  final bool joinView;
  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {

  LatLng x = LatLng(0, 0);
  List<dynamic>? events;
  @override
  Widget build(BuildContext context) {
    String title = "Events";
    if (widget.joinView) {
      title = "Registred Events";
    }

    try {
      return Screen(
          ab: buildAppBar(context, title,
              search: true, searchWidget: eventSearchWidget()),
          builder: (x) {
            return BuildFuture(
              callback: () async {
                if (widget.joinView) {
                  return getJoinedEvents();
                } else {
                  return getEvents();
                }
              },
              mapper: (resdata) => mapObjs(resdata.data['events'], toEvent),
              builder: (data) {
                events = data;
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: events?.length,
                  itemBuilder: (context, index) {
                    Event eventx = events![index];
                    return EventCard(eventx: eventx,);
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
