// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import '../screens/settings.dart';
import '../utilities/shared.dart';

class UserDrawer extends StatelessWidget {
  UserDrawer({
    super.key,
    required this.name,
    required this.email,
    required this.picURL,
    required this.homeScreen,
    required this.joinedScreen,
  });

  String name;
  String email;
  String picURL;
  Widget homeScreen;
  Widget joinedScreen;


  @override
  Widget build(BuildContext context) {
    return  Drawer(
  child: ListView(
    children: <Widget>[
      UserAccountsDrawerHeader(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(picURL),
            fit: BoxFit.cover
          ),
        ),
        currentAccountPicture: InkWell(
          child: CircleAvatar(
            backgroundImage: NetworkImage(picURL),
          ),
        ),
        accountEmail: Text(
          email,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        accountName: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      ListTile(
        leading: const Icon(
          Icons.home,
        ),
        title: const Text('Home'),
        onTap: () {
          goto(context, homeScreen);
        },
      ),
      ListTile(
        leading: const Icon(
          Icons.event_available,
        ),
        title: const Text('Registred Events'),
        onTap: () {
          goto(context, joinedScreen);
        },
      ),
      const Divider(),
      ListTile(
        leading: const Icon(
          Icons.settings,
        ),
        title: const Text('Settings'),
        onTap: () {
          goto(context, const Settings());
        },
      ),
    ],
  ),
);

  }
}
