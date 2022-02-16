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
      .._positions = (fields[2] as List).cast<GeoPosition>();
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj._startTime)
      ..writeByte(1)
      ..write(obj._endTime)
      ..writeByte(2)
      ..write(obj._positions);
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
