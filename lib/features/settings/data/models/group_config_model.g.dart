// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_config_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroupConfigModelAdapter extends TypeAdapter<GroupConfigModel> {
  @override
  final typeId = 0;

  @override
  GroupConfigModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupConfigModel(
      groupName: fields[0] as String,
      isOnline: fields[1] as bool,
      branchName: fields[2] as String?,
      assignmentStartRow: (fields[3] as num).toInt(),
      assignmentEndRow: (fields[4] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, GroupConfigModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.groupName)
      ..writeByte(1)
      ..write(obj.isOnline)
      ..writeByte(2)
      ..write(obj.branchName)
      ..writeByte(3)
      ..write(obj.assignmentStartRow)
      ..writeByte(4)
      ..write(obj.assignmentEndRow);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupConfigModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
