import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/screens/event/view_event.dart';
import 'package:org/server.dart';
import 'package:org/utilities/shared.dart';
import '../main.dart';
import '../net/auth.dart';

Future<void> initlizeFirebase() async {
  await Firebase.initializeApp();
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> handleInApp() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    await sendLocalNotification(
        body: "${message.data['eventTitle']} Has Started");
     handleLocalNotification(message);
    // return await notificationHandler(message);
  });
}

Future<void> handleBackground() async {
  try {
    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      await Firebase.initializeApp();
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) async {
      return await notificationHandler(message);
    });
  } catch (e) {
    Console.log(e);
  }
}

Future<void> handleForeground() async {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) async {
    return await notificationHandler(message);
  });
}

Future<void> subscribeToTopic(String topic) async {
  await FirebaseMessaging.instance
      .subscribeToTopic(topic)
      .then((value) => Console.log("Subscribed To $topic"));
}

Future<void> unsubscribeFromTopic(String topic) async {
  await FirebaseMessaging.instance
      .unsubscribeFromTopic(topic)
      .then((value) => Console.log("Unsubscribed To $topic"));
}

Future<String?> getToken() async {
  return await FirebaseMessaging.instance.getToken();
}

Future<void> notifySubscribers(String topic, String eventId) async {
  Console.log({"topic": topic, "eventId": eventId});
  await POST(
      "$devServer/notify", 0, 'AT', {"topic": topic, "eventId": eventId});
}

Future<void> notificationHandler(RemoteMessage? message) async {
  if (await checkOrRenewTokens() == false) return;
  if (message == null) return;
  if (message.data['eventId'].toString().isEmpty) {
    Console.log("EVENTID IS NULL:${message.data['eventId']}");
    return;
  }
  goto(
      navigatorKey.currentState!.context,
      ViewEvent(
        eventId: message.data['eventId'],
      ));
}

intilizeLocalNotification() async {
  AwesomeNotifications().initialize(null, // icon for your app notification
      [
        NotificationChannel(
            channelKey: 'eventAlerts',
            channelName: 'Event Notifications',
            channelDescription:
                "Notification Of Events That This Devices Is Subscribed To",
            defaultColor: const Color.fromARGB(255, 231, 9, 9),
            ledColor: Colors.white,
            playSound: true,
            enableLights: true,
            enableVibration: true)
      ]);
}

Future<void> sendLocalNotification(
    {String title = 'A Event Has Started', required String body}) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 1, channelKey: 'eventAlerts', title: title, body: body));
}

void handleLocalNotification(RemoteMessage? message) async{
  if (await checkOrRenewTokens() == false) return;
  if (message == null) return;
  if (message.data['eventId'].toString().isEmpty) {
    Console.log("EVENTID IS NULL:${message.data['eventId']}");
    return;
  }
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: (receivedAction) async {
      goto(
          navigatorKey.currentState!.context,
          ViewEvent(
            eventId: message.data['eventId'],
          ));
    },
  );
}
