import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_tracking_app/model/GeoPosition.dart';
import 'package:personal_tracking_app/model/Track.dart';

class Recorder {

  bool _isRecording = false;

  double _latitude = 0;
  double _longitude = 0;
  double _speed = 0;
  DateTime? _timestamp;

  StreamSubscription<Position>? positionStream;

  //ValueNotifier _notifier = ValueNotifier(_timestamp);



  Future<void> _updatePosition(Track track) async {

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position pos) {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
      _speed = pos.speed;
      _timestamp = pos.timestamp;
      print(_latitude.toString() + ' - ' + _longitude.toString() + ' - ' + _speed.toString());
      track.startTime ??= pos.timestamp;
      GeoPosition newPos = GeoPosition.fromPosition(_latitude, _longitude, _speed, _timestamp);
      track.positions.add(newPos);
      track.endTime = pos.timestamp;
      track.save();
    });
  }


  void startRecording() {
    _isRecording = true;
    final newTrack = Track();
    Hive.box('tracks').add(newTrack);
    _updatePosition(newTrack);
  }

  Future<void> stopRecording() async {
    positionStream?.cancel();
    _isRecording = false;
  }


  // Getter & Setter
  bool get isRecording => _isRecording;

  set isRecording(bool value) => _isRecording = value;

  get speed => _speed;

  get longitude => _longitude;

  get latitude => _latitude;

  get timestamp => _timestamp;
}