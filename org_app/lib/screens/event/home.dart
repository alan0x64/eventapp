// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  LatLng x = LatLng(0, 0);
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: ()async {
        setState(() {});
      },
      child: Screen(
          ab: buildAppBar(context, "Home"),
          builder: (data) => ListView.builder(
            itemCount: 0,
                itemBuilder: (context, index) {
                  return const Text("Empty");
                },
              )),
    );
  }
}
