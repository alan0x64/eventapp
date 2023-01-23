import 'package:flutter/material.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/net/auth.dart';
import 'package:org/servers.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(
      details,
      forceReport: true,
    );
  };

  runApp(const MaterialApp(
    home: App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: ElevatedButton(
                onPressed: (() async {

                }),
                child: const Text("Req"))));
  }
}
