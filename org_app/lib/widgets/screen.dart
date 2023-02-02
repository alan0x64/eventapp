import 'package:flutter/material.dart';
import 'package:org/models/org.dart';
import 'package:org/screens/event/new_event.dart';
import 'package:org/screens/org/view_org.dart';
import 'package:org/widgets/drawer.dart';
import 'package:org/widgets/future_builder.dart';
import '../screens/event/home.dart';

class Screen extends StatefulWidget {
  final AppBar ab;
  final Widget wid;

  const Screen({
    super.key,
    required this.ab,
    required this.wid,
  });

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  @override
  Widget build(BuildContext context) {
    return BuildFuture(
      callback: getProfile,
      mapper: mapOrg,
      builder: (data) {
        return Scaffold(
          drawer: UserDrawer(
            email: data.email,
            name: data.orgName,
            picURL: data.orgPic,
            bgURL: data.orgBackgroundPic,
            profileScreen: ProfileScreen(
              data: data,
            ),
            addEventScreen: const AddEvent(),
            homeScreen: const Home(),
            boxColor: const Color.fromARGB(255, 192, 148, 46),
          ),
          appBar: widget.ab,
          body: widget.wid,
        );
      },
    );
  }
}
