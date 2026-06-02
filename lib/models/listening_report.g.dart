// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listening_report.dart';

class ListeningSessionAdapter extends TypeAdapter<ListeningSession> {
  @override
  final int typeId = 2;

  @override
  ListeningSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return ListeningSession(
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime,
      averageVolume: fields[2] as double,
      peakVolume: fields[3] as double,
      eqPresetUsed: fields[4] as String,
      deviceId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ListeningSession obj) {
    writer.writeByte(6);
    writer.writeByte(0); writer.write(obj.startTime);
    writer.writeByte(1); writer.write(obj.endTime);
    writer.writeByte(2); writer.write(obj.averageVolume);
    writer.writeByte(3); writer.write(obj.peakVolume);
    writer.writeByte(4); writer.write(obj.eqPresetUsed);
    writer.writeByte(5); writer.write(obj.deviceId);
  }
}

class DailyReportAdapter extends TypeAdapter<DailyReport> {
  @override
  final int typeId = 3;

  @override
  DailyReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return DailyReport(
      date: fields[0] as DateTime,
      totalMinutes: fields[1] as int? ?? 0,
      avgVolume: fields[2] as double? ?? 0,
      sessionCount: fields[3] as int? ?? 0,
      riskLevel: fields[4] as String? ?? '安全',
    );
  }

  @override
  void write(BinaryWriter writer, DailyReport obj) {
    writer.writeByte(5);
    writer.writeByte(0); writer.write(obj.date);
    writer.writeByte(1); writer.write(obj.totalMinutes);
    writer.writeByte(2); writer.write(obj.avgVolume);
    writer.writeByte(3); writer.write(obj.sessionCount);
    writer.writeByte(4); writer.write(obj.riskLevel);
  }
}
