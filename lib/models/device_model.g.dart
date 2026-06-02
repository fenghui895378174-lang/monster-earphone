// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_model.dart';

class BluetoothDeviceModelAdapter extends TypeAdapter<BluetoothDeviceModel> {
  @override
  final int typeId = 0;

  @override
  BluetoothDeviceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return BluetoothDeviceModel(
      id: fields[0] as String,
      name: fields[1] as String,
      leftBattery: fields[2] as int? ?? 100,
      rightBattery: fields[3] as int? ?? 100,
      caseBattery: fields[4] as int? ?? 100,
      isConnected: fields[5] as bool? ?? false,
      rssi: fields[6] as int? ?? -50,
      lastLocation: fields[7] as String?,
      lastDisconnectedAt: fields[8] as DateTime?,
      audioCodec: fields[9] as String? ?? 'AAC',
      firmwareVersion: fields[10] as String?,
      firstPairedAt: fields[11] as DateTime? ?? DateTime.now(),
      totalListeningMinutes: fields[12] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, BluetoothDeviceModel obj) {
    writer.writeByte(13);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.name);
    writer.writeByte(2); writer.write(obj.leftBattery);
    writer.writeByte(3); writer.write(obj.rightBattery);
    writer.writeByte(4); writer.write(obj.caseBattery);
    writer.writeByte(5); writer.write(obj.isConnected);
    writer.writeByte(6); writer.write(obj.rssi);
    writer.writeByte(7); writer.write(obj.lastLocation);
    writer.writeByte(8); writer.write(obj.lastDisconnectedAt);
    writer.writeByte(9); writer.write(obj.audioCodec);
    writer.writeByte(10); writer.write(obj.firmwareVersion);
    writer.writeByte(11); writer.write(obj.firstPairedAt);
    writer.writeByte(12); writer.write(obj.totalListeningMinutes);
  }
}
