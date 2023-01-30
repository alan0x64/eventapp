// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';

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
  });

  String name;
  String email;
  Color boxColor;
  String picURL;
  
  Widget profileScreen;
  Widget homeScreen;
  Widget addEventScreen;


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: boxColor),
            currentAccountPicture:InkWell(
              onTap: () {
              Navigator.pop(context);
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => profileScreen));
              },
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
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => homeScreen));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.add,
            ),
            title: const Text('New Event'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => addEventScreen));
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
