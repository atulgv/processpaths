// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EntryOrderAdapter extends TypeAdapter<EntryOrder> {
  @override
  final int typeId = 3;

  @override
  EntryOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EntryOrder(
      id: fields[0] as String,
      entryId: fields[2] as String,
      sortIndex: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, EntryOrder obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.entryId)
      ..writeByte(3)
      ..write(obj.sortIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
