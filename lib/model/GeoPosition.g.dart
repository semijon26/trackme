// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GeoPosition.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GeoPositionAdapter extends TypeAdapter<GeoPosition> {
  @override
  final int typeId = 2;

  @override
  GeoPosition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GeoPosition()
      .._latitude = fields[0] as double?
      .._longitude = fields[1] as double?
      .._speed = fields[2] as double?
      .._altitude = fields[3] as double?
      .._timestamp = fields[4] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, GeoPosition obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj._latitude)
      ..writeByte(1)
      ..write(obj._longitude)
      ..writeByte(2)
      ..write(obj._speed)
      ..writeByte(3)
      ..write(obj._altitude)
      ..writeByte(4)
      ..write(obj._timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
