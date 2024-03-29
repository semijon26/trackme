import 'dart:async';
import 'package:flutter/foundation.dart';
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
  //late BuildContext _context;

  StreamSubscription<Position>? positionStream;
  late LocationSettings locationSettings;

  Recorder(/*BuildContext context*/) {
    locationSettings = _getLocationSettings();
    //_context = context;
  }

  LocationSettings _getLocationSettings() {
    //var t = AppLocalizations.of(_context)!;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
        foregroundNotificationConfig: ForegroundNotificationConfig(
          //notificationTitle: t.runningInBackground,
          //notificationText: t.trackMeWillContinueReceiveLocation,
          notificationTitle: "Die App läuft im Hintergrund weiter",
          notificationText:
              "TrackMe wird weiterhin deine Position ermitteln, auch wenn die App im Hintergrund ist",
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
          accuracy: LocationAccuracy.best,
          activityType: ActivityType.fitness,
          distanceFilter: 5,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true);
    } else {
      return const LocationSettings(
          accuracy: LocationAccuracy.best, distanceFilter: 5);
    }
  }

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
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position pos) {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
      _speed = pos.speed == -1 ? 0 : pos.speed;
      _altitude = pos.altitude;
      _timestamp = pos.timestamp;
      if (kDebugMode) {
        print(pos.latitude.toString() +
            ' - ' +
            pos.longitude.toString() +
            ' - ' +
            pos.speed.toString() +
            ' - ' +
            pos.altitude.toString());
      }
      track?.startTime ??= pos.timestamp;
      GeoPosition newPos = GeoPosition.fromPosition(
          _latitude, _longitude, _speed, _timestamp, _altitude);
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
    if (!(track!.isValidTrack())) {
      track?.delete();
    }
  }

  get speed => _speed;

  get longitude => _longitude;

  get latitude => _latitude;

  get timestamp => _timestamp;

  get altitude => _altitude;
}
