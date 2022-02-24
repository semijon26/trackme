import 'dart:async';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personal_tracking_app/recorder.dart';
import 'package:personal_tracking_app/ui/track_detail_page.dart';
import 'package:personal_tracking_app/model/geo_position.dart';
import 'package:personal_tracking_app/model/track.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../value_format.dart';

Recorder recorder = Recorder();
DateTime? _startButtonTimestamp;
String _fullPath = "";

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
  late Timer _timer;
  bool _isRecording = recorder.isRecording;
  var timestamp = ValueNotifier(recorder.timestamp);

  void _switchRecordingStatus() {
    setState(() {
      if (!_isRecording) {
        _startButtonTimestamp = DateTime.now();
        recorder.startRecording();
        _isRecording = recorder.isRecording;
      } else {
        recorder.stopRecording();
        _isRecording = recorder.isRecording;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        bottom: const TabBar(indicatorColor: Colors.white, tabs: [
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
      child: ValueListenableBuilder(
        valueListenable: timestamp,
        builder: (context, n, c) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 220,
                width: 300,
                child: Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isRecording ? recorder.latitude.toString() : '--',
                          style: const TextStyle(
                              fontSize: 30,
                              color: Color.fromRGBO(132, 128, 0, 100)),
                        ),
                        const Text('Latitude'),
                        const Text(''),
                        Text(
                          _isRecording ? recorder.longitude.toString() : '--',
                          style: const TextStyle(
                              fontSize: 30,
                              color: Color.fromRGBO(132, 128, 0, 100)),
                        ),
                        const Text('Longitude'),
                        const Text(''),
                        Text(
                          _isRecording
                              ? ValueFormat().formatAltitude(recorder.altitude)
                              : '--',
                          style: const TextStyle(
                              fontSize: 24,
                              color: Color.fromRGBO(132, 128, 0, 100)),
                        ),
                        const Text('Altitude'),
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
                      margin: const EdgeInsets.only(right: 15, bottom: 20),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isRecording ? _getRecordingTime() : '--',
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.indigo),
                            ),
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
                      margin: const EdgeInsets.only(left: 15, bottom: 20),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isRecording
                                  ? ValueFormat()
                                      .formatAndCheckSpeedValue(recorder.speed)
                                  : '--',
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.indigo),
                            ),
                            const Text('Speed'),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(300, 120),
                    primary: _getStartStopButtonColor(),
                  ),
                  onPressed: _switchRecordingStatus,
                  child: _getStartStopButtonIcon(),
                ),
              ),
              ElevatedButton(
                  style: _getPhotoButtonStyle(),
                  onPressed: _isRecording ? _takePhoto : () {},
                  child: const Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                    size: 30,
                  )),
            ],
          );
        },
      ),
    );
  }

  ButtonStyle _getPhotoButtonStyle() {
    if (_isRecording) {
      return ElevatedButton.styleFrom(
          fixedSize: const Size(300, 70),
          primary: const Color.fromRGBO(132, 128, 0, 100));
    }
    return ElevatedButton.styleFrom(
        splashFactory: NoSplash.splashFactory,
        fixedSize: const Size(300, 70),
        primary: Colors.black12.withOpacity(.01));
  }

  Color _getStartStopButtonColor() {
    if (_isRecording) {
      return const Color.fromRGBO(204, 0, 0, 100);
    }
    return Colors.indigo;
  }

  Icon _getStartStopButtonIcon() {
    if (_isRecording) {
      return const Icon(Icons.stop, color: Colors.white, size: 100);
    }
    return const Icon(Icons.play_arrow, color: Colors.white, size: 100);
  }

  void _takePhoto() async {
    print('taking photo');
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;

    var path = await getApplicationDocumentsDirectory();
    var directory =
        await Directory('${path.path}/photos').create(recursive: true);
    _fullPath = "${directory.path}/${image.name}";
    final imageTemporary = File(image.path);
    await imageTemporary.copy(_fullPath);

    recorder.track!.addPhoto(_fullPath);
  }

  Widget buildListView(BuildContext context) {
    return WatchBoxBuilder(
        box: Hive.box('tracks'),
        builder: (context, tracksBox) {
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: tracksBox.length,
            itemBuilder: (context, index) {
              final track = tracksBox.getAt(index) as Track;
              return Card(
                  child: Slidable(
                closeOnScroll: true,
                dragStartBehavior: DragStartBehavior.start,
                endActionPane: ActionPane(
                  extentRatio: .35,
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => track.delete(),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Track from ' +
                          (track.startTime != null
                              ? ValueFormat().dateFormatter.format(track.startTime!.toLocal())
                              : 'unknown'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  minVerticalPadding: 10,
                  contentPadding: const EdgeInsets.only(
                      left: 16, right: 16, top: 7, bottom: 7),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text('Start Time: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(track.startTime != null
                              ? ValueFormat().timeFormatter.format(track.startTime!.toLocal())
                              : 'unknown'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('End Time: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(track.endTime != null
                              ? ValueFormat().timeFormatter.format(track.endTime!.toLocal())
                              : 'unknown'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Max. Speed: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(ValueFormat()
                              .formatAndCheckSpeedValue(track.maxSpeed)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Avg. Speed: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(ValueFormat()
                              .formatAndCheckSpeedValue(track.avgSpeed)),
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

  String _getRecordingTime() {
    Duration d = DateTime.now().difference(_startButtonTimestamp!);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

String get fullPath => _fullPath;
