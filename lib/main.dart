import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:personal_tracking_app/ui/record_page.dart';
import 'package:personal_tracking_app/ui/saved_page.dart';
import 'package:personal_tracking_app/model/geo_position.dart';
import 'package:personal_tracking_app/model/track.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    /*if (Platform.isIOS) {
      return CupertinoApp(
        debugShowCheckedModeBanner: true,
        title: 'TrackMe',
        theme: CupertinoThemeData(
          primaryColor: Colors.indigo,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FutureBuilder(
          future: Hive.openBox('tracks'),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                return MyHomePage(title: 'TrackMe');
              }
            } else {
              return const Scaffold();
            }
          },
        ),
      );
    } else {*/
      return MaterialApp(
        debugShowCheckedModeBanner: true,
        title: 'TrackMe',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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
   // }
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
    var t = AppLocalizations.of(context)!;

    /*if(Platform.isIOS) {
      return CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.album_outlined),
                label: t.record),
                BottomNavigationBarItem(
                    icon: Icon(Icons.save),
                    label: t.saved),
              ]
          ),
          tabBuilder: (context, index) {
            if (index == 0) {
              return CupertinoTabView(
                navigatorKey: firstTabNavKey,
                builder: (BuildContext context) => RecordPage(),
              );
            } else {
              return CupertinoTabView(
                navigatorKey: secondTabNavKey,
                builder: (BuildContext context) => SavedPage(),
              );
            }
          });

    } else {*/
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Text(widget.title),
          automaticallyImplyLeading: false,
          bottom: TabBar(
              indicatorColor: Colors.white,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              tabs: [
                Tab(text: t.record, icon: const Icon(Icons.album_outlined)),
                Tab(text: t.saved, icon: const Icon(Icons.save)),
              ]),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          children: [
            RecordPage(),
            const SavedPage(),
          ],
        ),
      );
   // }

  }
}
