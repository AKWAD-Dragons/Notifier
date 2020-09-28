import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class FCMProvider {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final BehaviorSubject<String> fcmTokenSubject = BehaviorSubject<String>();
  final PublishSubject<Map<String, String>> notificationSubject =
      PublishSubject<Map<String, String>>();
  final PublishSubject<NotificationState> trayNotificationSubject =
      PublishSubject<NotificationState>();

  void setFCMBackgroundMessageHandler({
    @required Function(Map<String, dynamic>) launchTrayByMessage,
    @required Function(Map<String, dynamic>) launchTrayByMessageIOS,
    @required Function(Map<String, dynamic>) navigateByMessage,
    @required Function(Map<String, dynamic>) navigateByMessageIOS,
  }) {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (Platform.isIOS) {
          launchTrayByMessageIOS(message);
          return;
        }
        print("onMessage: $message");

        if (launchTrayByMessage == null) return;
        launchTrayByMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        if (Platform.isIOS) {
          navigateByMessageIOS(message);
          return;
        }
        print("onResume: $message");

        if (navigateByMessage == null) return;
        navigateByMessage(message);
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
