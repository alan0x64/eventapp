import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';
import './server.dart';
import 'net/auth.dart';
import 'screens/error.dart';
import 'screens/event/home.dart';
import 'screens/login.dart';
import 'utilities/notofocation.dart';
import 'utilities/providers.dart';
import 'utilities/shared.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// DotEnv dotenv = DotEnv() is automatically called during import.
// If you want to load multiple dotenv files or name your dotenv object differently, you can do the following and import the singleton into the relavant files:
// DotEnv another_dotenv = DotEnv()


void main() async {
  host(kReleaseMode);
  WidgetsFlutterBinding.ensureInitialized();
  await intilizeLocalNotification();
  await initlizeFirebase();
  await handleBackground();
  await handleForeground();
  await handleInApp();
  await dotenv.load(fileName: ".env");


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
