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

  @HiveField(3)
  double _avgSpeed = 0;

  @HiveField(4)
  double _maxSpeed = 0;

  @HiveField(5)
  int _totalDistance = 0;

  @HiveField(6)
  // ignore: prefer_final_fields
  var _photos = <String>[]; // saves path with file name of every photo

  @HiveField(7)
  double _minAltitude = 0;

  @HiveField(8)
  double _maxAltitude = 0;


  void addPosition(GeoPosition position) {
    _positions.add(position);
  }

  void addPhoto(String path) {
    _photos.add(path);
  }

  GeoPosition getPositionAt(int index) {
    return _positions[index];
  }

  calculateTrackData() {
    _avgSpeed = _calcAvgSpeed();
    _maxSpeed = _calcMaxSpeed();
    _minAltitude = _calcMinAltitude();
    _maxAltitude = _calcMaxAltitude();
    _totalDistance = _calcTotalDistance();
  }

  double _calcAvgSpeed() {
    double avg = 0;
    for (GeoPosition pos in _positions) {
      if (pos.speed != null) {
        avg = avg + pos.speed!;
      }
    }
    avg = avg / _positions.length;
    return avg;
  }

  double _calcMaxSpeed() {
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

  double _calcMinAltitude() {
    double min = double.infinity;
    for (GeoPosition pos in _positions) {
      if (pos.altitude != null) {
        if (pos.altitude! < min) {
          min = pos.altitude!;
        }
      }
    }
    return min;
  }

  double _calcMaxAltitude() {
    double max = 0;
    for (GeoPosition pos in _positions) {
      if (pos.altitude != null) {
        if (pos.altitude! > max) {
          max = pos.altitude!;
        }
      }
    }
    return max;
  }

  int _calcTotalDistance() {
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

  double get avgSpeed => _avgSpeed;

  double get maxSpeed => _maxSpeed;

  double get minAltitude => _minAltitude;

  double get maxAltitude => _maxAltitude;

  int get totalDistance => _totalDistance;

  List<String> get photos => _photos;

  @override
  String toString() {
    return 'Track{_startTime: $_startTime, _endTime: $_endTime, poslist}';
  }

}
