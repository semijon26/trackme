import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_tracking_app/ui/main.dart';

import '../model/Track.dart';

class TrackDetailPage extends StatelessWidget {
  DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  DateFormat timeFormatter = DateFormat('h:mm a');
  final Track track;

  TrackDetailPage(this.track, {Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 90,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 15, right: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((track.totalDistance() != -1 ? track.totalDistance().toString() + "m" : 'unknown'),
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.brown),),
                            const Text('Distance'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 90,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 15, left: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((getDuration(track) != null ? getDuration(track)! : 'unknown'),
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.brown),),
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
                    height: 90,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 15, right: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((track.startTime != null ? timeFormatter.format(track.startTime!.toLocal()) : 'unknown'),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.brown),),
                            const Text('Start Time'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 90,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 15, left: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((track.startTime != null ? timeFormatter.format(track.endTime!.toLocal()) : 'unknown'),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.brown),),
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
                    height: 90,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 15, right: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_formatAndCheckSpeedValue(track.maxSpeed()),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.brown),),
                            const Text('Max Speed'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 90,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 15, left: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_formatAndCheckSpeedValue(track.avgSpeed()),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.brown),),
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
