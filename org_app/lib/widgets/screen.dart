import 'package:flutter/material.dart';
import 'package:org/models/org.dart';
import 'package:org/screens/event/new_event.dart';
import 'package:org/screens/org/view_org.dart';
import 'package:org/widgets/drawer.dart';
import 'package:org/widgets/future_builder.dart';
import '../screens/event/home.dart';

class Screen extends StatefulWidget {
  final AppBar? ab;
  final Widget Function(dynamic data) builder;

  const Screen({
    super.key,
    required this.builder,
    this.ab,
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
            profileScreen:  ProfileScreen(),
            addEventScreen: const AddEvent(),
            homeScreen: const Home(),
          ),
          appBar: widget.ab,
          body: widget.builder(data),
        );
      },
    );
  }
}
