// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:org/utilities/shared.dart';

import '../screens/settings.dart';

class UserDrawer extends StatelessWidget {
  UserDrawer({
    super.key,
    required this.name,
    required this.email,
    required this.picURL,
    required this.homeScreen,
    required this.addEventScreen,
    required this.bgURL,
  });

  String name;
  String email;
  String picURL;
  String bgURL;

  Widget homeScreen;
  Widget addEventScreen;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(bgURL), fit: BoxFit.cover)),
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
              Icons.add,
            ),
            title: const Text('New Event'),
            onTap: () {
              goto(context, addEventScreen);
            },
          ),
          const Divider(),
           ListTile(
            leading: const Icon(
              Icons.settings,
            ),
            title: const Text('Settings'),
            onTap: () {
              goto(context,const Settings());
            },
          ),
          const ListTile(),
          const ListTile(),
          const ListTile(),
        ],
      ),
    );
  }
}
