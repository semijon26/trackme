import 'dart:math';

import 'package:intl/intl.dart';

import 'model/track.dart';

class ValueFormat {
  DateFormat dateFormatter = DateFormat('dd.MM.yyyy');
  DateFormat timeFormatter = DateFormat('H:mm');

  String? getDuration(Track track) {
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

  String formatAndCheckSpeedValue(double speedInMetersPerSec) {
    speedInMetersPerSec = speedInMetersPerSec * 3.6;
    String s = "";
    if (speedInMetersPerSec.isNaN || speedInMetersPerSec.isInfinite) {
      return s;
    } else {
      num mod = pow(10.0, 2);
      s = ((speedInMetersPerSec * mod).round().toDouble() / mod).toString();
    }
    return '$s km/h';
  }

  String formatAltitude(double altitude) {
    return "${altitude.round().toString()} m";
  }
}
