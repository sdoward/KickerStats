import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stm_kicker/rankingspage.dart';
import 'package:stm_kicker/stmstats.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'creategame.dart';

Future<void> main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'STMKicker',
    options: const FirebaseOptions(
      googleAppID: '',
      apiKey: '',
      projectID: 'stmkicker',
    ),
  );
  final Firestore firestore = Firestore(app: app);
  await firestore.settings(timestampsInSnapshotsEnabled: true);
  runApp(STMKickerApp());
}

class STMKickerApp extends StatelessWidget {

  FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'STM Kicker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        routes: <String, WidgetBuilder>{
          '/createGame': (BuildContext context) => CreateGamePage(),
          '/stmStats': (BuildContext context) => STMStatsPage(),
        },
        home: MainPage());
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("STM Kicker"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.assessment),
              onPressed: () {
                Navigator.of(context).pushNamed("/stmStats");
              },
            )
          ],
        ),
        body: RankingsPage(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed("/createGame");
          },
          child: Icon(Icons.add),
        ));
  }
}
