// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:org/models/org.dart';
import 'package:org/net/auth.dart';

class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;
  String text = "Something Went Wrong!";

  ErrorScreen({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      text = errorDetails.summary.toString();
    }
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Expanded(
                flex: 1,
                child:
                    Image(image: AssetImage('assets/backgrounds/error.png'))),
            if (kDebugMode) const Divider(),
            if (kDebugMode)
              Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Container(
                        margin: const EdgeInsets.all(5),
                        child: Text(errorDetails.toString())),
                  )),
            const Divider(),
            Expanded(
              flex: 0,
              child: Container(
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                    onPressed: () async {
                      await logout();
                      await clearTokens();
                      Phoenix.rebirth(context);
                    },
                    child: const Text("Restart App")),
              ),
            )
          ],
        )),
      ),
    );
  }
}
