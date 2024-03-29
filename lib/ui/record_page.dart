import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../recorder.dart';
import '../utils/value_format.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

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
  String _fullPath = "";
  late TextEditingController controller;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });
    _isRecording = recorder.isRecording;
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    controller.dispose();
    super.dispose();
  }

  void _switchRecordingStatus() {
    setState(() {
      if (!_isRecording) {
        _startButtonTimestamp = DateTime.now();
        recorder.startRecording();
        _isRecording = recorder.isRecording;
      } else {
        _showAlertDialog(context);
      }
    });
  }

  _showAlertDialog(BuildContext context) {
    var t = AppLocalizations.of(context)!;

    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(t.cancel));

    Widget confirmButton = TextButton(
        onPressed: () async {
          recorder.stopRecording();
          bool? isSuccessful = recorder.track?.isValidTrack();
          _isRecording = recorder.isRecording;
          Navigator.of(context, rootNavigator: true).pop();
          if (isSuccessful!) {
            var name = await _enterNameDialog();
            if (name == "") {
              name = null;
            }
            name != null
                ? recorder.track?.name = name
                : recorder.track?.name = t.unnamedTrack;
            recorder.track?.save();
            Fluttertoast.showToast(
                msg: t.savedToastMsg,
                backgroundColor: Colors.grey.shade200,
                textColor: Colors.indigo);
          } else {
            Fluttertoast.showToast(
                msg: t.notSavedToastMsg,
                backgroundColor: Colors.grey.shade200,
                textColor: Colors.indigo);
          }
        },
        child: Text(t.stop));

    AlertDialog alert = AlertDialog(
      title: Text(t.stopRecording),
      actions: [cancelButton, confirmButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<String?> _enterNameDialog() {
    var t = AppLocalizations.of(context)!;

    submit() {
      Navigator.of(context).pop(controller.text);
      controller.clear();
    }

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.submitTrackName),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: t.unnamedTrack),
          controller: controller,
          onSubmitted: (_) => submit(),
        ),
        actions: [
          TextButton(
            child: Text(t.submit),
            onPressed: submit,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var t = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
            child: Column(
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
                        _isRecording
                            ? recorder.latitude
                                .toString()
                                .characters
                                .take(12)
                                .string
                            : '--',
                        style: const TextStyle(
                            fontSize: 30,
                            color: Color.fromRGBO(132, 128, 0, 100)),
                      ),
                      Text(t.latitude),
                      const Text(''),
                      Text(
                        _isRecording
                            ? recorder.longitude
                                .toString()
                                .characters
                                .take(12)
                                .string
                            : '--',
                        style: const TextStyle(
                            fontSize: 30,
                            color: Color.fromRGBO(132, 128, 0, 100)),
                      ),
                      Text(t.longitude),
                      const Text(''),
                      Text(
                        _isRecording
                            ? ValueFormat().formatAltitude(recorder.altitude)
                            : '--',
                        style: const TextStyle(
                            fontSize: 24,
                            color: Color.fromRGBO(132, 128, 0, 100)),
                      ),
                      Text(t.altitude),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 90,
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
                          Text(t.recordingTime),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 90,
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
                          Text(t.speed),
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
                  fixedSize: const Size(300, 120), backgroundColor: _getStartStopButtonColor(),
                ),
                onPressed: _switchRecordingStatus,
                child: _getStartStopButtonIcon(),
              ),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(300, 70),
                    backgroundColor: const Color.fromRGBO(132, 128, 0, 100)),
                onPressed: _isRecording ? _takePhoto : null,
                child: const Icon(
                  Icons.add_a_photo,
                  color: Colors.white,
                  size: 30,
                )),
          ],
        )),
      ),
    );
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

  String get fullPath => _fullPath;

  @override
  bool get wantKeepAlive => true;
}
