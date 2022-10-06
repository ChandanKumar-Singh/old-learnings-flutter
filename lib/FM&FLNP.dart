import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FMFLNP extends StatefulWidget {
  const FMFLNP({Key? key}) : super(key: key);

  @override
  State<FMFLNP> createState() => _FMFLNPState();
}

class _FMFLNPState extends State<FMFLNP> {
  //1 create a cm instance
  FirebaseMessaging cm = FirebaseMessaging.instance;

  //2 Notification permission
  void requestNotificationPermission() async {
    NotificationSettings settings = await cm.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        provisional: false,
        sound: true);
    print('Authorization Status : ${settings.authorizationStatus}');
  }

  //3 get token for testing
  void getToken() async {
    var token = await cm.getToken();
    print(
        '--------------------------------------- $token ----------------------------------');
  }

  //Flutter local notifications
  // 1 initialize the plugin
  void initializeFLN() {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@drawable/ic_stat_android');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    FlutterLocalNotificationsPlugin().initialize(initializationSettings,
        onSelectNotification: (str) => print('Fluttter local Notifcations'));
  }

  //Foreground Messaging
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'channel_id',
    'channel_name',
    description: 'channel_description',
    importance: Importance.max,
    playSound: true,
    showBadge: true,
  );

  void foregroundMessage() async {
    FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    FirebaseMessaging.onMessage.listen((event) {
      print(event);
      RemoteNotification? remoteNotification = event.notification;
      AndroidNotification? androidNotification = event.notification?.android;
      if (androidNotification != null && remoteNotification != null) {
        plugin.show(
            remoteNotification.hashCode,
            remoteNotification.title,
            remoteNotification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: androidNotification.smallIcon,
                // other properties...
              ),
            ));
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestNotificationPermission();
    getToken();
    initializeFLN();
    foregroundMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Text('Hiii'),
    ));
  }
}
