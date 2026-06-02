// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soundscape.dart';

class SoundscapeAdapter extends TypeAdapter<Soundscape> {
  @override
  final int typeId = 4;

  @override
  Soundscape read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Soundscape(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      category: fields[3] as String,
      isPlaying: fields[4] as bool? ?? false,
      volume: fields[5] as double? ?? 0.5,
    );
  }

  @override
  void write(BinaryWriter writer, Soundscape obj) {
    writer.writeByte(6);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.name);
    writer.writeByte(2); writer.write(obj.icon);
    writer.writeByte(3); writer.write(obj.category);
    writer.writeByte(4); writer.write(obj.isPlaying);
    writer.writeByte(5); writer.write(obj.volume);
  }
}
