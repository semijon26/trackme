import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:personal_tracking_app/Recorder.dart';
import 'package:personal_tracking_app/ui/TrackDetailPage.dart';
import 'package:personal_tracking_app/model/GeoPosition.dart';
import 'package:personal_tracking_app/model/Track.dart';
import 'dart:math';
import 'package:flutter_slidable/flutter_slidable.dart';

Recorder recorder = Recorder();
DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
DateFormat timeFormatter = DateFormat('h:mm a');

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TrackAdapter());
  Hive.registerAdapter(GeoPositionAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
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
                child: MyHomePage(title: 'Personal Tracking App'),
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
  bool _isRecording = recorder.isRecording;

  void _switchRecordingStatus() {
    setState(() {
      if (!_isRecording) {
        // nimmt noch nicht auf -> starte
        recorder.startRecording();
        _isRecording = recorder.isRecording;
      } else {
        // nimmt schon auf -> stoppe
        recorder.stopRecording();
        _isRecording = recorder.isRecording;
      }
    });
  }

  void _refreshData() {
    Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    //_refreshData();  -------------NOTWENDIG UM INFOS STÄNDIG ZU AKTUALISIEREN, aber verursacht Performance Verlust---------

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        bottom: const TabBar(tabs: [
          Tab(text: 'RECORD', icon: Icon(Icons.album_outlined)),
          Tab(text: 'SAVED', icon: Icon(Icons.save)),
        ]),
      ),
      body: TabBarView(
        children: [
          buildMainPage(),
          buildListView(context),
        ],
      ),
    );
  }

  Center buildMainPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 180,
            width: 300,
            child: Card(
              margin: const EdgeInsets.only(bottom: 30),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_isRecording ? recorder.latitude.toString() : '--'),
                    const Text('Latitude'),
                    Text(''),
                    Text(_isRecording ? recorder.longitude.toString() : '--'),
                    const Text('Longitude'),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 150,
                child: Card(
                  margin: const EdgeInsets.only(right: 15, bottom: 30),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text(_isRecording ? 'z.B. 00:03:26' : '--'),
                        const Text('Recording Time'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 120,
                width: 150,
                child: Card(
                  margin: const EdgeInsets.only(left: 15, bottom: 30),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_isRecording ? formatAndCheckSpeedValue(recorder.speed) : '--'),
                        const Text('Speed'),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Size(300, 150),
              primary: _getStartStopButtonColor(),
            ),
            onPressed: _switchRecordingStatus,
            child: _getStartStopButtonIcon(),
          ),
        ],
      ),
    );
  }

  Color _getStartStopButtonColor() {
    if (_isRecording) {
      return Colors.red;
    }
    return Colors.green;
  }

  Icon _getStartStopButtonIcon() {
    if (_isRecording) {
      return const Icon(Icons.stop, color: Colors.white, size: 100);
    }
    return const Icon(Icons.play_arrow, color: Colors.white, size: 100);
  }


  Widget buildListView(BuildContext context) {
    return WatchBoxBuilder(
        box: Hive.box('tracks'),
        builder: (context, tracksBox) {
          return ListView.builder(
            itemCount: tracksBox.length,
            itemBuilder: (context, index) {
              final track = tracksBox.getAt(index) as Track;
              return Card(
                  elevation: 5,
                  child: Slidable(
                    closeOnScroll: true,
                    dragStartBehavior: DragStartBehavior.start,
                    endActionPane: ActionPane(
                      extentRatio: .3,
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => track.delete(),
                          backgroundColor: const Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        'Track from ' +
                            (track.startTime != null
                                ? dateFormatter
                                    .format(track.startTime!.toLocal())
                                : 'unknown'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      minVerticalPadding: 15,
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text('Start Time: ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(track.startTime != null
                                  ? timeFormatter
                                      .format(track.startTime!.toLocal())
                                  : 'unknown'),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('End Time: ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(track.endTime != null
                                  ? timeFormatter
                                      .format(track.endTime!.toLocal())
                                  : 'unknown'),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Max. Speed: ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(formatAndCheckSpeedValue(track.maxSpeed())),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Avg. Speed: ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(formatAndCheckSpeedValue(track.avgSpeed())),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TrackDetailPage(track)));
                      },
                    ),
                  ));
            },
          );
        });
  }

  String formatAndCheckSpeedValue(double speedInMetersPerSec) {
    speedInMetersPerSec = speedInMetersPerSec * 3.6;
    String s = "";
    if (speedInMetersPerSec.isNaN || speedInMetersPerSec.isInfinite) {
      return "unknown";
    } else {
      num mod = pow(10.0, 2);
      s = ((speedInMetersPerSec * mod).round().toDouble() / mod).toString();
    }
    return '$s km/h';
  }
}