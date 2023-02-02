// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Screen(
        ab: AppBar(),
        wid: Center(
            child: ElevatedButton(
                onPressed: () async {
                  await const FlutterSecureStorage().deleteAll();
                  snackbar(
                      context, "Tokens Are Cleared , You must login again", 1);
                },
                child: const Text("Clear Storage"))));
  }
}