
import 'package:hive_flutter/hive_flutter.dart';

part 'geo_position.g.dart';

@HiveType(typeId: 2)
class GeoPosition extends HiveObject {

  @HiveField(0)
  double? _latitude;

  @HiveField(1)
  double? _longitude;

  @HiveField(2)
  double? _speed;

  @HiveField(3)
  double? _altitude;

  @HiveField(4)
  DateTime? _timestamp;


  GeoPosition();

  GeoPosition.fromPosition(double latitude, double longitude, double speed, DateTime? timestamp, double altitude) {
    this._latitude = latitude;
    this._longitude = longitude;
    this._speed = speed;
    this._timestamp = timestamp;
    this._altitude = altitude;
  }

  double? get speed => _speed;

  double? get longitude => _longitude;

  double? get latitude => _latitude;

  double? get altitude => _altitude;

  DateTime? get timestamp => _timestamp;

  @override
  String toString() {
    return 'GeoPosition{_latitude: $_latitude, _longitude: $_longitude, _speed: $_speed, _altitude: $_altitude _timestamp: $_timestamp}';
  }
}