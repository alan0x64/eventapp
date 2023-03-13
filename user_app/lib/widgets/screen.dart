import 'package:flutter/material.dart';

import '../models/user.dart';
import '../screens/event/home.dart';
import 'drawer.dart';
import 'future_builder.dart';

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
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: BuildFuture(
        callback: () async {
          return await getLogedInUser();
        },
        mapper: (resData) {
          return toUser(resData.data);
        },
        builder: (data) {
          return Scaffold(
            drawer: UserDrawer(
              email: data.email,
              name: data.fullName,
              picURL: data.profilePic,
              homeScreen: const Home(),
              joinedScreen: const Home(joinView: true),
            ),
            appBar: widget.ab,
            body: widget.builder(data),
          );
        },
      ),
    );
  }
}
