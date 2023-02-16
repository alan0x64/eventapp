
import 'package:flutter/material.dart';
import 'package:org/utilities/shared.dart';

import '../screens/users/user_view.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String imageUrl;
  final String userId;
  final String phoneNumber;
  final String eventId;
  final bool blacklist ;



  const UserCard({super.key, 
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.imageUrl,
    required this.eventId,
    this.blacklist=false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      child: Card(
        color: ThemeData.dark().cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            goto(context, UserProfilePage(
              userId: userId, 
              eventId: eventId,
              blacklist: blacklist,
              ));
          },
          child: Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(16),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(imageUrl),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      name,
                      style:  const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      phoneNumber,
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
      ),
    );
  }
}
