import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

class FCMProvider {
  final Function(Map<String, dynamic>) _launchTrayByMessage;
  final Function(Map<String, dynamic>) _launchTrayByMessageIOS;
  final Function(Map<String, dynamic>) _navigateByMessage;
  final Function(Map<String, dynamic>) _navigateByMessageIOS;

  FCMProvider(
    this._launchTrayByMessage,
    this._launchTrayByMessageIOS,
    this._navigateByMessage,
    this._navigateByMessageIOS,
  ) {
    setFCMBackgroundMessageHandler();
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final BehaviorSubject<String> fcmTokenSubject = BehaviorSubject<String>();
  final PublishSubject<Map<String, String>> notificationSubject =
      PublishSubject<Map<String, String>>();
  final PublishSubject<NotificationState> trayNotificationSubject =
      PublishSubject<NotificationState>();

  void setFCMBackgroundMessageHandler() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (Platform.isIOS) {
          _launchTrayByMessageIOS(message);
          return;
        }
        print("onMessage: $message");

        if (_launchTrayByMessage == null) return;
        _launchTrayByMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        if (Platform.isIOS) {
          _navigateByMessageIOS(message);
          return;
        }
        print("onResume: $message");

        if (_navigateByMessage == null) return;
        _navigateByMessage(message);
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
