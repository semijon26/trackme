// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final int typeId = 1;

  @override
  Track read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Track()
      ..startTime = fields[0] as DateTime?
      ..endTime = fields[1] as DateTime?
      .._positions = (fields[2] as List).cast<GeoPosition>()
      .._avgSpeed = fields[3] as double
      .._maxSpeed = fields[4] as double
      .._totalDistance = fields[5] as int
      .._photos = (fields[6] as List).cast<String>()
      .._minAltitude = fields[7] as double
      .._maxAltitude = fields[8] as double
      ..name = fields[9] as String?;
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.endTime)
      ..writeByte(2)
      ..write(obj._positions)
      ..writeByte(3)
      ..write(obj._avgSpeed)
      ..writeByte(4)
      ..write(obj._maxSpeed)
      ..writeByte(5)
      ..write(obj._totalDistance)
      ..writeByte(6)
      ..write(obj._photos)
      ..writeByte(7)
      ..write(obj._minAltitude)
      ..writeByte(8)
      ..write(obj._maxAltitude)
      ..writeByte(9)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
