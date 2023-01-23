// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';

class UserDrawer extends StatelessWidget {

  UserDrawer({
    super.key,
    required this.name,
    required this.email,
    required this.picURL,
    required this.profile,
    required this.home,
    required this.add,
    this.boxColor = Colors.red,
  });

  String name;
  String email;
  Color boxColor;
  String picURL;
  
  Widget profile;
  Widget home;
  Widget add;


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
                MaterialPageRoute(builder: (context) => profile));
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => home));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.add,
            ),
            title: const Text('New Event'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => add));
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
