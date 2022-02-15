
import 'package:hive_flutter/hive_flutter.dart';

part 'GeoPosition.g.dart';

@HiveType(typeId: 2)
class GeoPosition extends HiveObject {

  @HiveField(0)
  double? _latitude;

  @HiveField(1)
  double? _longitude;

  @HiveField(2)
  double? _speed;

  @HiveField(3)
  DateTime? _timestamp;

  GeoPosition();

  GeoPosition.fromPosition(double latitude, double longitude, double speed, DateTime? timestamp) {
    this._latitude = latitude;
    this._longitude = longitude;
    this._speed = speed;
    this._timestamp = timestamp;
  }

  double? get speed => _speed;

  double? get longitude => _longitude;

  double? get latitude => _latitude;

  DateTime? get timestamp => _timestamp;

  @override
  String toString() {
    return 'GeoPosition{_latitude: $_latitude, _longitude: $_longitude, _speed: $_speed, _timestamp: $_timestamp}';
  }
}