import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';

import 'model/Notification.dart';
import 'notifcations/badge.dart';
import 'notifcations/card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Notify',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(
          title: 'Notification',
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("MessageID: ${message.messageId}");
}

class _MyHomePageState extends State<MyHomePage> {
  List<Notification> _listNotification  = [];

  @override
  void initState() {
    registerNotification();

    super.initState();
  }

  void registerNotification() async {
    await Firebase.initializeApp();

    FirebaseMessaging.instance.getToken().then((token) {
      print('FCM TOKEN: ${token}');
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("Receive Notification");
      print(event.notification!.title);
      print(event.notification!.body);
      Notification newNotification = Notification(
        title: event.notification?.title,
        body: event.notification?.body,
      );
      setState(() {
        _listNotification = List.from(_listNotification)
          ..add(newNotification);
      });


      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(event.notification!.title.toString()),
              content: Text(event.notification!.body!),
              actions: [
                TextButton(
                  child: Text("Done"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });


  }

  void removeItem(var index){
    List<Notification> _newList = _listNotification;
    var n = _newList.removeAt(index);
    // print(n.title);
    setState(() {
      _listNotification = _newList;
    });
  }

  void removeItemAll(){
    print("Clear Notification");
    setState(() {
      _listNotification = [];
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        itemCount: _listNotification.length,
        itemBuilder: (BuildContext context, int index) {
          return CardNotification(_listNotification[index].title, _listNotification[index].body, index, removeItem);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => removeItemAll(),
        backgroundColor: Colors.red,
        child: const Icon(Icons.remove_circle_outline),
      ),
    );
  }
}
