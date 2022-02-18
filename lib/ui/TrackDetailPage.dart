import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../model/Track.dart';

DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
DateFormat timeFormatter = DateFormat('h:mm a');


class TrackDetailPage extends StatefulWidget {

  final Track track;

  TrackDetailPage(this.track, {Key? key}) : super(key: key);


  @override
  State<TrackDetailPage> createState() {
    return _TrackDetailPage();
  }
}


class _TrackDetailPage extends State<TrackDetailPage> {

  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    Track track = widget.track;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share))
        ],
        title: Text(
          'Track from ' +
              (track.startTime != null
                  ? dateFormatter.format(track.startTime!.toLocal())
                  : 'unknown'),
        ),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 460,
                width: 360,
                margin: const EdgeInsets.only(bottom: 10),
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 11.0
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 5, right: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((track.totalDistance != -1 ? formatDistance(track.totalDistance) : 'unknown'),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.indigo),),
                            const Text('Distance'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 5, left: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((getDuration(track) != null ? getDuration(track)! : 'unknown'),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.indigo),),
                            const Text('Duration'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 5, right: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((track.startTime != null ? timeFormatter.format(track.startTime!.toLocal()) : 'unknown'),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.indigo),),
                            const Text('Start Time'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 5, left: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((track.startTime != null ? timeFormatter.format(track.endTime!.toLocal()) : 'unknown'),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.indigo),),
                            const Text('End Time'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 5, right: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_formatAndCheckSpeedValue(track.maxSpeed),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.indigo),),
                            const Text('Max Speed'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 5, left: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_formatAndCheckSpeedValue(track.avgSpeed),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.indigo),),
                            const Text('Avg Speed'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }

  String formatDistance(int distanceInMeters) {
    String s = "";
    if (distanceInMeters > 999) {
      double distanceInKilometers = distanceInMeters.toDouble();
      distanceInKilometers = distanceInKilometers / 1000;
      s = double.parse(distanceInKilometers.toStringAsFixed(2)).toString();
      s = '$s km';
    } else {
      s = '$distanceInMeters m';
    }
    return s;
  }

  String? getDuration (Track track) {
    DateTime? dtStart = track.startTime;
    DateTime? dtEnd = track.endTime;
    Duration duration;
    if (dtStart == null || dtEnd == null) {
      return null;
    }
    duration = dtEnd.difference(dtStart);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _formatAndCheckSpeedValue(double speedInMetersPerSec) {
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
