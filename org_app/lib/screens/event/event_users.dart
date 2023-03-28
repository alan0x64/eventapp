import 'package:flutter/material.dart';
import 'package:org/models/user.dart';
import 'package:org/screens/users/usersearch.dart';
import 'package:org/widgets/user_card.dart';

import '../../models/event.dart';
import '../../net/HTTP.dart';
import '../../utilities/shared.dart';
import '../../widgets/future_builder.dart';

class ViewEventUser extends StatefulWidget {
  final String eventId;
  final bool blacklist;
  final bool registred;
  final bool showControl;
  final bool attended;


  const ViewEventUser({
    super.key,
    required this.eventId,
    this.blacklist = false,
    this.registred = false,
    this.showControl = true,
    this.attended = false,

  });

  @override
  State<ViewEventUser> createState() => _ViewEventUser();
}

class _ViewEventUser extends State<ViewEventUser> {
  List<dynamic>? users;
  String screenTitle = "Attenders";
  Future<Response> Function()? cb;

  @override
  Widget build(BuildContext context) {
    int lnum=0;
    cb = () async => await getAttenders(widget.eventId);

    if (widget.blacklist) {
      screenTitle = 'Blacklisted';
      lnum = 2;
      cb = () async => await getBlacklistMembers(widget.eventId);
    } else if (widget.registred) {
      screenTitle = 'Registred Users';
      lnum = 1;
      cb = () async => await getEventMembers(widget.eventId);
    }else if (widget.attended) {
      screenTitle = 'Attended Users';
      lnum = 3;
      cb = () async => await getAttended(widget.eventId);
    }

    return BuildFuture(
      callback: cb!,
      mapper: (resdata) {
        return mapObjs(resdata.data['members'], toUser);
      },
      builder: (data) {
        return Scaffold(
          appBar: buildAppBar(context, screenTitle,
              button: const BackButton(),
              search: true,
              searchWidget: userSearch(
                lnum,
                eventId: widget.eventId,
                blacklist: widget.blacklist,
                showControl: widget.showControl,
              )),
          body: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: data?.length,
            itemBuilder: (context, index) {
              User userx = data![index];
              return Container(
                padding: const EdgeInsets.only(top: 5),
                child: UserCard(
                  eventId: widget.eventId,
                  user: userx,
                  blacklist: widget.blacklist,
                  // showControl: widget.showControl,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
