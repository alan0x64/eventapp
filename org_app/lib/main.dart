import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:org/net/auth.dart';
import 'package:org/screens/error.dart';
import 'package:org/screens/event/home.dart';
import 'package:org/screens/login.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(
      details,
      forceReport: true,
    );
  };
  runApp(
    Phoenix(
      child: MaterialApp(
        home: const App(),
        debugShowCheckedModeBanner: false,
        builder: (BuildContext context, Widget? widget) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return ErrorScreen(errorDetails: errorDetails,);
          };
          return widget!;
        },
      ),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: isTokenExp("RT"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            if (snapshot.data == false) return const Home();
            return const LoginScreen();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
        }
        return const Center(child: LinearProgressIndicator());
      },
    );
  }
}
