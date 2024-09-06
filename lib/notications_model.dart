import 'package:dripa/map.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'main.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class LocalNotificationManager {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<bool?> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    bool? initialized = await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationClick,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationClick,
    );

    return initialized;
  }

  Future<void> showNotification({
    int id = 0,
    String title = '',
    String body = '',
    String payload = '',
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      channelDescription: 'Your Channel Description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
  int generateRandomUid() {
    Random random = Random();
    return 100000 + random.nextInt(900000);
  }
  Future<void> scheduledNotification({
    int id = 0,
    String title = '',
    String body = '',
    String payload = '',
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      channelDescription: 'Your Channel Description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    id = generateRandomUid();
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      payload: payload,
      androidAllowWhileIdle: true,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

void onNotificationClick(NotificationResponse response) async {
  navigatorKey.currentState?.push(MaterialPageRoute(
    builder: (context) =>  const NotificationsScreen(
      allnotifications: [],
      hroute: false,),
  ));
}

void onBackgroundNotificationClick(NotificationResponse response) async {
  navigatorKey.currentState?.push(MaterialPageRoute(
    builder: (context) =>  const NotificationsScreen(allnotifications: [],
      hroute: false,),
  ));
}
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  _firebaseMessaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // Handle the background message, e.g., show a notification
}
class NotifyFirebase {
  Newsfeedservice news = Newsfeedservice();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final local =flutterLocalNotificationsPlugin;
  final adroidchannel= const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notification',
      description: 'this channel is used for important notifications',
      importance: Importance.defaultImportance
  );
  void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }
  Future<void> initNotifications() async {
    showToastMessage('Initializing notifications');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      collectionNamefor = prefs.getString('cname')?? '';
      String fcmToken = prefs.getString('fcmToken')?? '';
      if (collectionNamefor.isEmpty) {
        collectionNamefor = "";
        showToastMessage('fetching collection name');
      }
      DocumentSnapshot documentSnapshot= await FirebaseFirestore.instance.collection("${collectionNamefor}s").doc(FirebaseAuth.instance.currentUser!.uid).get();
      await  _setCurrentLocation(documentSnapshot.reference);
    } catch (error) {
      showToastMessage('Error initializing notifications: $error');
      // Handle error as needed
    }
  }

  Future<void>signOut(BuildContext context,Person person)async{
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      showToastMessage('saving data');
      final String url ='$baseUrl/addSignOutData';
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (collectionNamefor.isEmpty) {
        collectionNamefor = "";
        showToastMessage('collection is empty');
      }
      Map<String, dynamic> data = {
        'collection':"${collectionNamefor}s",
        'userId':userId,
      };
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        print('Data added successfully.');
        showToastMessage(response.statusCode.toString());
        showToastMessage('success updating doc');
        prefs.clear();
        showToastMessage('success in clearing preference');
        await FirebaseMessaging.instance.deleteToken();
        showToastMessage('success in deleting token');
        await FirebaseAuth.instance.signOut();
        showToastMessage('success in signing out');
        navigateBottomBar(context,person);
      } else {
        print('Failed to add data: ${response.body}');
        showToastMessage(response.statusCode.toString());
      }
    }catch(e){
      showToastMessage('error:$e');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("An error occured during logging out"),
              content: Text("$e")
          );
        },
      );
    }
  }


  Future<void>saveSingIn(Map<String,dynamic>data,BuildContext context,Person person)async{
    final String url ='$baseUrl/addSignInData';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        print('Data added successfully.');
        showToastMessage(response.statusCode.toString());
        NotifyFirebase().notify();
        NotifyFirebase().loginNotification(data['userId']);
        navigateBottomBar(context,person);
        showToastMessage("success");
      } else {
        print('Failed to add data: ${response.body}');
        showToastMessage(response.statusCode.toString());
      }
    } catch (e) {
      print('Error: $e');
      showToastMessage(e.toString());
    }
  }
  void navigateBottomBar(BuildContext context,Person person)async{
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    await Future.delayed(Duration(seconds: 1));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => TripPage(person: person,)),
          (Route<dynamic> route) => false,
    );
  }
  Future<String?> requestFCMToken() async {
    try {
      await firebaseMessaging.requestPermission();
      return await firebaseMessaging.getToken();
    } catch (error) {
      showToastMessage('Error requesting FCM token: $error');
      return null;
    }
  }
  Future<void> sendChatToCloudFunction(Map<String, dynamic> chatData) async {
    const String cloudFunctionUrl = 'YOUR_CLOUD_FUNCTION_URL';
    final String jsonData = jsonEncode(chatData);
    try {
      final response = await http.post(
        Uri.parse(cloudFunctionUrl),
        body: jsonData,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print('Chat sent successfully');
        showToastMessage(response.statusCode.toString());
      } else {
        print('Failed to send chat. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending chat: $error');
    }
  }




  Future<void> _setCurrentLocation(DocumentReference collectionRef) async {
    try {
      final Timestamp createdAt = Timestamp.now();
      Position location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double clongitude=location.longitude;
      double clatitude=location.latitude;
      final doc= await collectionRef.get();
      if(doc.exists){
        var oldData=doc.data() as Map<String, dynamic>;
        Map<String, dynamic> newData = {};
        if (createdAt != oldData['ctimestamp']) {
          newData['ctimestamp'] = createdAt;
        }
        if(clongitude!=oldData['clogitude']){
          newData['clongitude']=clongitude;
        }
        if(clatitude!=oldData['clatitude']){
          newData['clatitude']=clatitude;
        }
        if (newData.isNotEmpty) {
          await doc.reference.update(newData);
        }
      }
      showToastMessage('current location added');
    } catch (error) {
      showToastMessage('Error setting current location: $error');
    }
  }

  int generateRandomUid() {
    Random random = Random();
    return 100000 + random.nextInt(900000);
  }
  Future<void>notify()async{
    try {
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
      firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        sound: true,
        badge: true,
      );
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        try {
          final notif = message.ttl;
          int id = generateRandomUid();
          if (notif == null) return;
          AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
              adroidchannel.id,
              adroidchannel.name,
              channelDescription: adroidchannel.description,
              importance: adroidchannel.importance,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher'
          );

          NotificationDetails platformChannelSpecifics = NotificationDetails(
              android: androidPlatformChannelSpecifics);
          local.show(
              id,
              message.notification?.title,
              message.notification?.body,
              platformChannelSpecifics,
              payload: jsonEncode(message.toMap())
          );
          showToastMessage("notification recieved");
        }catch(e){
          showToastMessage("error:$e");
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        try{
          final notif = message.ttl;
          int id = generateRandomUid();
          if (notif == null) return;
          AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
            adroidchannel.id,
            adroidchannel.name,
            channelDescription: adroidchannel.description,
            importance: adroidchannel.importance,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
          );

          NotificationDetails platformChannelSpecifics = NotificationDetails(
              android: androidPlatformChannelSpecifics);
          local.show(
              id,
              message.notification?.title,
              message.notification?.body,
              platformChannelSpecifics,
              payload: jsonEncode(message.toMap())
          );
          showToastMessage("notification recieved");
        }catch(e){
          showToastMessage("error:$e");
        }
      });
      FirebaseMessaging.instance.getInitialMessage().then((value) =>
          handleMessage(value!));
      showToastMessage('notifications  initialized');
    }catch(e){
      showToastMessage('notifications not initialized, error:$e');
    }
  }
  void handleMessage(RemoteMessage message){
    navigatorKey.currentState?.pushNamed(
      NotificationsScreen.route,
      arguments: message,
    );
  }


  Future initLocalNotification()async{
    const android=AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings=InitializationSettings(android: android,);
    local.initialize(
      settings,
    );

  }
  String baseUrl='https://us-central1-fans-arena.cloudfunctions.net';
  void sendfollowingNotifications(String currentuserId,otherId)async{
    try{
      final response = await http.get(Uri.parse('$baseUrl/sendfollowingNotifications?uid1=$currentuserId&uid2=$otherId'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        showToastMessage('${response.statusCode}');
      } else {
        throw Exception('Failed to sendfollowingnotification1');
      } }catch(e){
      showToastMessage(e.toString());
    }
  }
  void loginNotification (String userId)async{
    try{
      final response = await http.get(Uri.parse('$baseUrl/loginNotification?uid=$userId'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        showToastMessage('${response.statusCode}');
      } else {
        throw Exception('Failed to loginNotification ');
      } }catch(e){
      showToastMessage(e.toString());
    }
  }
}


class NotificationsScreen extends StatefulWidget {
  final List<NotificationModel> allnotifications;
  final bool hroute;
  const NotificationsScreen({super.key, required this.allnotifications, required this.hroute});
  static const String route = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
String collectionNamefor="";

class Newsfeedservice{

}

class NotificationModel {
  final Person from;
  final Person to;
  final String time;
  final String Date;
  final String message;
  final String content;
  final Timestamp timestamp;
  NotificationModel({
    required this.from,
    required this.message,
    required this.time,
    required this.content,
    required this.to,
    required this.Date,
    required this.timestamp,
  });
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? createdAtJson = json['createdAt']??{
      "_seconds": 0,
      "_nanoseconds": 0
    };
    DateTime createdDateTime = DateTime.fromMillisecondsSinceEpoch(
        createdAtJson!['_seconds'] * 1000 + createdAtJson['_nanoseconds'] ~/ 1000000);

    DateTime now = DateTime.now();
    Duration difference = now.difference(createdDateTime);

    String formattedTime = '';
    String hours = DateFormat('HH').format(createdDateTime);
    String minutes = DateFormat('mm').format(createdDateTime);
    String t = DateFormat('a').format(createdDateTime);
    if (difference.inSeconds == 1) {
      formattedTime = 'now';
    } else if (difference.inSeconds < 60) {
      formattedTime = 'now';
    } else if (difference.inMinutes == 1) {
      formattedTime = '${difference.inMinutes} minute ago';
    } else if (difference.inMinutes < 60) {
      formattedTime = '${difference.inMinutes} minutes ago';
    } else if (difference.inHours == 1) {
      formattedTime = '${difference.inHours} hour ago';
    } else if (difference.inHours < 24) {
      formattedTime = '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      formattedTime = '${difference.inDays} day ago';
    } else if (difference.inDays < 7) {
      formattedTime = '${difference.inDays} days ago';
    } else if (difference.inDays ==7) {
      formattedTime = '${difference.inDays ~/ 7} weeks ago';
    } else {
      formattedTime = DateFormat('d MMM').format(createdDateTime);
    }
    Timestamp timestamp = Timestamp.fromDate(createdDateTime);
    return NotificationModel(
      from: Person(name:json['from']['username']??'',
        url: json['from']['profileImage']??'',
        collectionName: json['from']['collectionName']??'',
        userId: json['from']['userId']??'',),
      to:Person(name:json['username']??'',
        url: json['to']['profileImage']??'',
        collectionName:json['to']['collectionName']??'',
        userId: json['to']['userId']??'',),
      message:json['message'],
      time:'at $hours:$minutes $t',
      content:json['content'],
      Date: formattedTime,
      timestamp: timestamp,);

  }
}

class Person{
  String userId;
  String url;
  String name;
  String collectionName;
  String location;
  Timestamp? timestamp;
  String motto;
  String genre;
  Person({required this.name,
    required this.url,
    required this.collectionName,
    required this.userId,
    this.location='',
    this.timestamp,
    this.motto='',
    this.genre='',
  });
  Map<String, dynamic> toMap() {
    return {
      'name':name,
      'url':url,
      'collection':collectionName,
      'userId':userId,
      'location':location,
      'genre': genre,
    };
  }

  factory Person.fromJson(Map<String, dynamic> map) {
    Timestamp convertToTimestamp(dynamic value) {
      if (value is Map<String, dynamic>) {
        int seconds = value['_seconds'] ?? 0;
        int nanoseconds = value['_nanoseconds'] ?? 0;
        return Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanoseconds ~/ 1000000,
        ));
      }
      return Timestamp.now();
    }
    return Person(
        name: map['name'],
        url:map['url'],
        collectionName: map['collection'],
        userId: map['userId'],
        location: map['location'],
        genre: map['genre'],
        timestamp: convertToTimestamp(map['createdAt'])
    );
  }
}
