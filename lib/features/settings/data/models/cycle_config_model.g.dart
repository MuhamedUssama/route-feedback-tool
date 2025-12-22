// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_config_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CycleConfigModelAdapter extends TypeAdapter<CycleConfigModel> {
  @override
  final typeId = 1;

  @override
  CycleConfigModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CycleConfigModel(
      cycleNumber: (fields[0] as num).toInt(),
      trackName: fields[1] as String,
      groups: (fields[2] as List).cast<GroupConfigModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, CycleConfigModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.cycleNumber)
      ..writeByte(1)
      ..write(obj.trackName)
      ..writeByte(2)
      ..write(obj.groups);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CycleConfigModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
