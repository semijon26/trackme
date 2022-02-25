import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../recorder.dart';
import '../value_format.dart';

class RecordPage extends StatefulWidget {
  RecordPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RecordPageState();
  }
}

class _RecordPageState extends State<RecordPage>
    with AutomaticKeepAliveClientMixin<RecordPage> {
  Recorder recorder = Recorder();
  DateTime? _startButtonTimestamp;
  late Timer _timer;
  late bool _isRecording;
  late var _timestamp;
  String _fullPath = "";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });
    _isRecording = recorder.isRecording;
    _timestamp = ValueNotifier(recorder.timestamp);
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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

  String _getRecordingTime() {
    Duration d = DateTime.now().difference(_startButtonTimestamp!);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

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
    return Center(
      child: ValueListenableBuilder(
        valueListenable: _timestamp,
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

  String get fullPath => _fullPath;
}
