import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:org/net/auth.dart';
import 'package:org/screens/error.dart';
import 'package:org/screens/event/home.dart';
import 'package:org/screens/login.dart';
import 'package:org/utilities/notofocation.dart';
import 'package:org/utilities/providers.dart';
import 'package:org/utilities/shared.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';
import './server.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  host(false);
  WidgetsFlutterBinding.ensureInitialized();
  await intilizeLocalNotification();
  await initlizeFirebase();
  await handleBackground();
  await handleForeground();
  await handleInApp();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(
      details,
      forceReport: true,
    );
  };
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LocationProvider()),
    ],
    child: Phoenix(
      child: ThemeProvider(
        themes: [
          AppTheme.dark(),
          AppTheme.light(),
        ],
        child: ThemeConsumer(child: Builder(
          builder: (context) {
            return MaterialApp(
              routes: {
                '/': (context) => const App(),
              },
              initialRoute: '/',
              navigatorKey: navigatorKey,
              theme: ThemeProvider.themeOf(context).data,
              debugShowCheckedModeBanner: false,
              builder: (BuildContext context, Widget? widget) {
                ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                  return ErrorScreen(
                    errorDetails: errorDetails,
                  );
                };
                return widget!;
              },
            );
          },
        )),
      ),
    ),
  ));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    try {
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
    } catch (e) {
      clearTokens();
      Console.logError(e.toString());
      return Container(
          margin: const EdgeInsets.all(20),
          child: const Center(child: Text("NETWORK ERROR")));
    }
  }
}
