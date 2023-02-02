// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:org/utilities/shared.dart';

class UserDrawer extends StatelessWidget {
  UserDrawer({
    super.key,
    required this.name,
    required this.email,
    required this.picURL,
    required this.profileScreen,
    required this.homeScreen,
    required this.addEventScreen,
    required this.boxColor,
    required this.bgURL,
  });

  String name;
  String email;
  Color boxColor;
  String picURL;
  String bgURL;

  Widget profileScreen;
  Widget homeScreen;
  Widget addEventScreen;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
                color: boxColor,
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
              Icons.person,
            ),
            title: const Text('Account'),
            onTap: () {
              goto(context, profileScreen);
            },
          ),
          const Divider(),
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
          const ListTile(),
          const ListTile(),
          const ListTile(),
        ],
      ),
    );
  }
}
