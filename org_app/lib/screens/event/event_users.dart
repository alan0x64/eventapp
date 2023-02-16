import 'package:flutter/material.dart';
import 'package:org/models/user.dart';
import 'package:org/widgets/user_card.dart';

import '../../models/event.dart';
import '../../utilities/shared.dart';
import '../../widgets/future_builder.dart';

class ViewEventUser extends StatefulWidget {
  final String eventId;
  final bool blacklist;

  const ViewEventUser({
    super.key,
    required this.eventId,
    this.blacklist = false,
  });

  @override
  State<ViewEventUser> createState() => _ViewEventUser();
}

class _ViewEventUser extends State<ViewEventUser> {
  List<dynamic>? users;

  @override
  Widget build(BuildContext context) {
      String screenTitle =
      widget.blacklist ? 'Blacklisted' : 'Attenders';
    return BuildFuture(
      callback: () => widget.blacklist
          ? getBlacklistMembers(widget.eventId)
          : getEventMembers(widget.eventId),
      mapper: (resdata) {
        return mapObjs(resdata.data['members'], toUser);
      },
      builder: (data) {
        return Scaffold(
          appBar:
              buildAppBar(context, screenTitle, button: const BackButton()),
          body: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: data?.length,
            itemBuilder: (context, index) {
              User userx = data![index];
              return UserCard(
                  eventId: widget.eventId,
                  name: userx.fullName,
                  email: userx.email,
                  imageUrl: userx.profilePic,
                  phoneNumber: userx.phoneNumber,
                  userId: userx.id,
                  blacklist: widget.blacklist,);
            },
          ),
        );
      },
    );
  }
}
