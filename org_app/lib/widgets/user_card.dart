import 'package:flutter/material.dart';
import 'package:org/utilities/shared.dart';

import '../models/user.dart';
import '../screens/users/user_view.dart';

class UserCard extends StatelessWidget {
  final User user;
  final String eventId;
  final int eventStatus;
  final bool blacklist;

  const UserCard({
    super.key,
    required this.user,
    required this.eventId,
    this.eventStatus=0 ,
    this.blacklist = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ThemeData.dark().cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          goto(
              context,
              UserProfilePage(
                userId: user.id,
                eventId: eventId,
                blacklist: blacklist,
              ));
        },
        child: Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(10, 15, 10,10),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(user.profilePic),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    user.phoneNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
