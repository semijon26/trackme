import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_tracking_app/model/geo_position.dart';
import 'package:personal_tracking_app/model/track.dart';

class Recorder {

  bool isRecording = false;

  double _latitude = 0;
  double _longitude = 0;
  double _speed = 0;
  double _altitude = 0;
  DateTime? _timestamp;
  Track? track;

  StreamSubscription<Position>? positionStream;

  static LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 2,
  );


  Future<void> _updatePosition() async {

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


    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position pos) {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
      _speed = pos.speed;
      _altitude = pos.altitude;
      _timestamp = pos.timestamp;
      print(_latitude.toString() + ' - ' + _longitude.toString() + ' - ' + _speed.toString() + ' - ' + _altitude.toString());
      track?.startTime ??= pos.timestamp;
      GeoPosition newPos = GeoPosition.fromPosition(_latitude, _longitude, _speed, _timestamp, _altitude);
      track?.positions.add(newPos);
      track?.endTime = DateTime.now();
      track?.calculateTrackData();
      track?.save();
    });
  }


  void startRecording() {
    isRecording = true;
    track = Track();
    Hive.box('tracks').add(track);
    _updatePosition();
  }

  Future<void> stopRecording() async {
    track?.endTime = DateTime.now();
    track?.calculateTrackData();
    track?.save();
    positionStream?.cancel();
    isRecording = false;
    if(track?.startTime == null || track?.positions.length == 0) {
      track?.delete();
    }
  }


  // Getter & Setter

  get speed => _speed;

  get longitude => _longitude;

  get latitude => _latitude;

  get timestamp => _timestamp;

  get altitude => _altitude;
}