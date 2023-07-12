import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcm_testing/data/data_repository.dart';
import 'package:fcm_testing/service/local_notifications_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late LocalNotificationService service;
  DataRepositroy dr = DataRepositroy();
  // andres
  String userID = 'Kt1NA4Bk59jQfkD7OlvT';
  // andy
  // String userID = 'tz5bgAC7IHdO8CIlkT3M';
  // bobby
  // String userID = 'tMQXkqs4BuPxO8UzLScj';

  @override
  void initState() {
    super.initState();
    service = LocalNotificationService();
    listenToNotification();
    service.initialize();
    requestPermission();
    getToken();
    initInfo();
  }

  void listenToNotification() =>
      service.onNotificationClick.stream.listen(onNotificationListener);

  void onNotificationListener(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      //Navigator.of(context).pushNamed('');
    }
  }

  void initInfo() {
    print('init start');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('.....onMessage.....');
      String? title = message.notification?.title;
      String? body = message.notification?.body;
      print('onMessage title: $title -- ');
      print('onMessage body: $body');
      service.showNotificationWithPayload(
        id: 0,
        title: 'title!',
        body: 'body!',
        payload: 'message.data[' ']',
      );
    });
    print('init end');
  }

  void getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print('token: $token');
    dr.addUpdateToken(userID, token);
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            '"Appbar"',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () async {
                  //await dr.createUser('Andres', 'Rogers', 'zoski@gmail.com', '123123');
                  //await dr.addNotificationSetting('Ethereum', 'ETH', 'UP', 7.5, userID, 'screen4');

                  print('db write written successfully');
                },
                child: Container(
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  child: const Center(
                    child: Text(
                      '"Button"',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () async {
            //     await service.showNotification(
            //       id: 0,
            //       title: 'Notification Title',
            //       body: 'Some body',
            //     );
            //   },
            //   child: const Text('Show local notification'),
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     await service.showScheduledNotification(
            //       id: 0,
            //       title: 'Noti Title',
            //       body: 'Some random strings',
            //       seconds: 3,
            //     );
            //   },
            //   child: const Text('Show scheduled notification'),
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     await service.showNotificationWithPayload(
            //       id: 0,
            //       title: 'Notification Title',
            //       body: 'Some body',
            //       payload: 'Payload navigation',
            //     );
            //   },
            //   child: const Text('Show notification with payload'),
            // ),
          ],
        ),
      ),
    );
  }
}
