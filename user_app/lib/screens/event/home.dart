// ignore_for_file: use_build_context_synchronously

import 'package:EventLink/widgets/status_filter.dart';
import 'package:EventLink/widgets/type_filter.dart';
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
  int selectedStatus = -1;
  int selectedType = -1;

  LatLng x = LatLng(0, 0);
  List<dynamic>? events;
  @override
  Widget build(BuildContext context) {
    String title = "Home";
    String screentext="Near By Events";

    if (widget.joinView) {
      title = "Registred Events";
      screentext="Events You're Part Of";
    }

    try {
      return Screen(
          ab: buildAppBar(context, title, search: true,
              searchWidget: eventSearchWidget(
            () {
              setState(() {});
            },
          )),
          builder: (x) {
            return Column(
              children: [
                StatusFilter(
                  selectedbutton: selectedStatus,
                  state: (selectbutton) {
                    selectedStatus = selectbutton;
                    setState(() {});
                  },
                ),
                TypeFilter(
                  selectedbutton: selectedType,
                  state: (selectbutton) {
                    selectedType = selectbutton;
                    setState(() {});
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
                      Text(screentext,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                BuildFuture(
                  callback: () async {
                    if (widget.joinView) {
                      return getJoinedEvents();
                    } else {
                      return getEvents(selectedStatus, selectedType);
                    }
                  },
                  mapper: (resdata) => mapObjs(resdata.data['events'], toEvent),
                  builder: (data) {
                    events = data;
                    return Expanded(
                        flex: 8,
                        child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: events?.length,
                            itemBuilder: (context, index) {
                              Event eventx = events![index];
                              if (events!.isNotEmpty) {
                                return EventCard(
                                  eventx: eventx,
                                );
                              } else {
                                return Container(
                                  margin: const EdgeInsets.all(100),
                                  child: const Center(
                                    child: Text("No Events"),
                                  ),
                                );
                              }
                            }));
                  },
                )
              ],
            );
          });
    } catch (e) {
      Console.log(e);
    }
    return const Text("data");
  }
}