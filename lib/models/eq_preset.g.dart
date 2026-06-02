// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eq_preset.dart';

class EQPresetAdapter extends TypeAdapter<EQPreset> {
  @override
  final int typeId = 1;

  @override
  EQPreset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return EQPreset(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      bands: (fields[3] as List).cast<double>(),
      isCustom: fields[4] as bool? ?? false,
      isActive: fields[5] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, EQPreset obj) {
    writer.writeByte(6);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.name);
    writer.writeByte(2); writer.write(obj.icon);
    writer.writeByte(3); writer.write(obj.bands);
    writer.writeByte(4); writer.write(obj.isCustom);
    writer.writeByte(5); writer.write(obj.isActive);
  }
}
