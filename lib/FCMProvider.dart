import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class FCMProvider {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final BehaviorSubject<String> fcmTokenSubject = BehaviorSubject<String>();
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final PublishSubject<Map<String, String>> notificationSubject =
      PublishSubject<Map<String, String>>();
  final PublishSubject<NotificationState> trayNotificationSubject =
      PublishSubject<NotificationState>();

  void setFCMBackgroundMessageHandler({
    @required Function(Map<String, dynamic>) onNotification,
    @required Function(Map<String, dynamic>) onNotificationIOS,
    @required Function(Map<String, dynamic>) onNotificatioClick,
    @required Function(Map<String, dynamic>) onNotificatioClickIOS,
    @required
        Function(int id, String title, String body, String payload)
            iosNotificationWidget,
  }) {
    _initLocalNotifications(iosNotificationWidget);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (Platform.isIOS) {
          onNotificationIOS(message);
          return;
        }
        if (onNotification != null) onNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        if (Platform.isIOS) {
          onNotificatioClickIOS(message);
          return;
        }
        if (onNotificatioClick != null) onNotificatioClick(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print('FCM NEW TOKEN : $token');
      fcmTokenSubject.add(token);
    });
  }

  void _initLocalNotifications(iosNotificationWidget) async {
    AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("ic_launcher_foreground");
    InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> notify(Map<String, dynamic> message) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "channelId",
      ".MainActivity",
      "channelDescription",
      priority: Priority.high,
      importance: Importance.max,
      ticker: "New notification",
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      message["notification"]["title"],
      message["notification"]["body"],
      notificationDetails,
    );
  }

  void cleanTokenListener() {
    fcmTokenSubject.close();
    notificationSubject.close();
    trayNotificationSubject.close();
  }
}

abstract class NotificationState {}

class InAppNotificationLaunched extends NotificationState {
  final Map<String, String> payloadMap;

  InAppNotificationLaunched(this.payloadMap);
}
