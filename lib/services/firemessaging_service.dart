import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/services/firestore_service.dart';

class FireMessagingService {
  final AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'donation_status', // id
    'Donation Status', // title
    'This channel is used to notify donation status.', // description
    importance: Importance.max,
  );
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final List<StreamSubscription> _subscriptions = [];

  void initToken(FireStoreService fireStore) async {
    // Get and store device token to db
    await fireStore.storeDeviceToken(await _messaging.getToken());
    // Store device token on refresh
    _subscriptions.add(_messaging.onTokenRefresh.listen((newToken) async {
      await fireStore.storeDeviceToken(newToken);
    }));
  }

  Future<void> initSettings() async {
    // Ask permission on IOS device
    await _messaging.requestPermission();

    // Set notification heads up
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Listen to notification on foreground
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification notification = message.notification;
        AndroidNotification android = message.notification?.android;
        if (notification != null && android != null) {
          _notificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                _channel.description,
                icon: android?.smallIcon,
                color: kDarkPrimaryColor,
              ),
            ),
            payload: message.data['id'],
          );
        }
      }),
    );
  }

  void handleNotification(Function(String) onData) async {
    // Handle notification tap on foreground
    await _notificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher_notification'),
        iOS: IOSInitializationSettings(),
      ),
      onSelectNotification: (payload) async {
        onData(payload);
        _flushMessage();
      },
    );

    // Handle notification tap from ternimated state
    RemoteMessage initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null && initialMessage.data.isNotEmpty) {
      onData(initialMessage.data['id']);
      _flushMessage();
    }

    // Handle notification tap on background
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message != null && message.data.isNotEmpty) {
          onData(message.data['id']);
          _flushMessage();
        }
      }),
    );
  }

  // Flush remaining messages (Dirty Code)
  void _flushMessage() async {
    RemoteMessage message;
    do {
      message = await FirebaseMessaging.instance.getInitialMessage();
    } while (message != null);
  }

  Future<void> clear(FireStoreService fireStore) async {
    await fireStore.removeDeviceToken(await _messaging.getToken());
    for (StreamSubscription subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
