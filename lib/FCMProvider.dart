import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

class FCMProvider {
  FCMProvider() {
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
          _launchTrayByMessageiOS(message);
          return;
        }
        _launchTrayByMessage(message);
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        if (Platform.isIOS) {
          _navigateByMessageiOS(message);
          return;
        }
        _navigateByMessage(message);
        print("onResume: $message");
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

  ///For foreground messages
  void _launchTrayByMessage(Map<String, dynamic> message) {
    String target = message['data']['target'];

    switch (target) {
      case 'room':
        String roomId = message['data']['room_id'];
        String tag = 'room';
        String body = message['notification']['body'];
        trayNotificationSubject.add(InAppNotificationLaunched(
            {'tag': tag, 'id': roomId, 'body': body}));
        break;

      case 'request':
        String requestID = message['data']['request_id'];
        String tag = 'request';
        String body = message['notification']['body'];
        trayNotificationSubject.add(InAppNotificationLaunched(
            {'tag': tag, 'id': requestID, 'body': body}));
        break;

      case 'billNote':
        String orderId = message['data']['order_id'];
        String tag = 'billNote';
        trayNotificationSubject
            .add(InAppNotificationLaunched({'tag': tag, 'id': orderId}));
        break;
    }
  }

  void _launchTrayByMessageiOS(Map<String, dynamic> message) {
    String target = message['target'];

    switch (target) {
      case 'room':
        String roomId = message['room_id'];
        String tag = 'room';
        String body = message['aps']['alert']['body'];
        trayNotificationSubject.add(InAppNotificationLaunched(
            {'tag': tag, 'id': roomId, 'body': body}));

        break;

      case 'request':
        String requestID = message['request_id'];
        String tag = 'request';
        String body = message['aps']['alert']['body'];
        trayNotificationSubject.add(InAppNotificationLaunched(
            {'tag': tag, 'id': requestID, 'body': body}));
        break;
    }
  }

  ///For background messages
  void _navigateByMessage(Map<String, dynamic> message) {
    String target = message['data']['target'];

    switch (target) {
      case 'room':
        String roomId = message['data']['room_id'];
        String tag = 'room';
        notificationSubject.add({'tag': tag, 'id': roomId});
        break;

      case 'request':
        String requestID = message['data']['request_id'];
        String tag = 'request';
        notificationSubject.add({'tag': tag, 'id': requestID});
        break;

      case 'order':
        String orderId = message['data']['order_id'];
        String tag = 'order';
        notificationSubject.add({'tag': tag, 'id': orderId});
        break;
    }
  }

  void _navigateByMessageiOS(Map<String, dynamic> message) {
    String target = message['target'];

    switch (target) {
      case 'room':
        String roomId = message['room_id'];
        String tag = 'room';
        notificationSubject.add({'tag': tag, 'id': roomId});
        break;

      case 'request':
        String requestID = message['request_id'];
        String tag = 'request';
        notificationSubject.add({'tag': tag, 'id': requestID});
        break;

      case 'order':
        String orderId = message['order_id'];
        String tag = 'order';
        notificationSubject.add({'tag': tag, 'id': orderId});
        break;
    }
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
