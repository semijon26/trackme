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
