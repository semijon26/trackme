import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'GeoPosition.dart';

part 'Track.g.dart';

@HiveType(typeId: 1)
class Track extends HiveObject {
  @HiveField(0)
  DateTime? _startTime;

  @HiveField(1)
  DateTime? _endTime;

  @HiveField(2)
  // ignore: prefer_final_fields
  var _positions = <GeoPosition>[];

  void addPosition(GeoPosition position) {
    _positions.add(position);
  }

  GeoPosition getPositionAt(int index) {
    return _positions[index];
  }

  double avgSpeed() {
    double avg = 0;
    for (GeoPosition pos in _positions) {
      if (pos.speed != null) {
        avg = avg + pos.speed!;
      }
    }
    avg = avg / _positions.length;
    return avg;
  }

  double maxSpeed() {
    double max = 0;
    for (GeoPosition pos in _positions) {
      if (pos.speed != null) {
        if (pos.speed! > max) {
          max = pos.speed!;
        }
      }
    }
    return max;
  }

  int totalDistance() {
    double totalDist = 0;

    for (GeoPosition pos1 in _positions) {
      if (pos1.latitude != null && pos1.longitude != null) {
        GeoPosition pos2;
        if (_positions.length > _positions.indexOf(pos1)+1) {
          pos2 = _positions.elementAt(_positions.indexOf(pos1)+1);
          if (pos2.latitude != null && pos2.longitude != null) {
            totalDist = totalDist + Geolocator.distanceBetween(pos1.latitude!, pos1.longitude!, pos2.latitude!, pos2.longitude!);
          }else {
            return -1;
          }
        }
      }
    }
    int totalDistRounded = totalDist.round();
    return totalDistRounded;
  }

  set startTime(DateTime? startTime) {
    _startTime = startTime;
  }

  set endTime(DateTime? endTime) {
    _endTime = endTime;
  }

  List<GeoPosition> get positions => _positions;

  DateTime? get endTime => _endTime;

  DateTime? get startTime => _startTime;

  @override
  String toString() {
    return 'Track{_startTime: $_startTime, _endTime: $_endTime, poslist}';
  }
}
