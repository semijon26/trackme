import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:personal_tracking_app/ui/record_page.dart';
import 'package:personal_tracking_app/ui/saved_page.dart';
import 'package:personal_tracking_app/model/geo_position.dart';
import 'package:personal_tracking_app/model/track.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TrackAdapter());
  Hive.registerAdapter(GeoPositionAdapter());
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackMe',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: FutureBuilder(
        future: Hive.openBox('tracks'),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return const DefaultTabController(
                length: 2,
                child: MyHomePage(title: 'TrackMe'),
              );
            }
          } else {
            return const Scaffold();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        bottom: const TabBar(
            indicatorColor: Colors.white,
            physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            tabs: [
              Tab(text: 'RECORD', icon: Icon(Icons.album_outlined)),
              Tab(text: 'SAVED', icon: Icon(Icons.save)),
            ]),
      ),
      body: TabBarView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: [
          RecordPage(),
          const SavedPage(),
        ],
      ),
    );
  }
}
