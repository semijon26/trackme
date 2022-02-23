// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Track.dart';

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
      .._startTime = fields[0] as DateTime?
      .._endTime = fields[1] as DateTime?
      .._positions = (fields[2] as List).cast<GeoPosition>()
      .._avgSpeed = fields[3] as double
      .._maxSpeed = fields[4] as double
      .._totalDistance = fields[5] as int
      .._photos = (fields[6] as List).cast<String>()
      .._minAltitude = fields[7] as double
      .._maxAltitude = fields[8] as double;
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj._startTime)
      ..writeByte(1)
      ..write(obj._endTime)
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
      ..write(obj._maxAltitude);
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
