import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'device_model.g.dart';

@HiveType(typeId: 0)
class BluetoothDeviceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int leftBattery;

  @HiveField(3)
  int rightBattery;

  @HiveField(4)
  int caseBattery;

  @HiveField(5)
  bool isConnected;

  @HiveField(6)
  int rssi;

  @HiveField(7)
  String? lastLocation;

  @HiveField(8)
  DateTime? lastDisconnectedAt;

  @HiveField(9)
  String? audioCodec;

  @HiveField(10)
  String? firmwareVersion;

  @HiveField(11)
  DateTime firstPairedAt;

  @HiveField(12)
  int totalListeningMinutes;

  BluetoothDeviceModel({
    required this.id,
    required this.name,
    this.leftBattery = 100,
    this.rightBattery = 100,
    this.caseBattery = 100,
    this.isConnected = false,
    this.rssi = -50,
    this.lastLocation,
    this.lastDisconnectedAt,
    this.audioCodec = 'AAC',
    this.firmwareVersion,
    DateTime? firstPairedAt,
    this.totalListeningMinutes = 0,
  }) : firstPairedAt = firstPairedAt ?? DateTime.now();

  double get averageBattery => (leftBattery + rightBattery) / 2;

  String get rssiLabel {
    if (rssi > -50) return '优秀';
    if (rssi > -65) return '良好';
    if (rssi > -80) return '一般';
    return '较差';
  }

  Color rssiColor() {
    if (rssi > -50) return const Color(0xFF00E676);
    if (rssi > -65) return const Color(0xFF00E5FF);
    if (rssi > -80) return const Color(0xFFFFAB40);
    return const Color(0xFFFF5252);
  }

  String get healthStatus {
    if (totalListeningMinutes > 10000) return '需关注';
    if (totalListeningMinutes > 5000) return '良好';
    return '优秀';
  }

  BluetoothDeviceModel copyWith({
    String? id,
    String? name,
    int? leftBattery,
    int? rightBattery,
    int? caseBattery,
    bool? isConnected,
    int? rssi,
    String? lastLocation,
    DateTime? lastDisconnectedAt,
    String? audioCodec,
    String? firmwareVersion,
    int? totalListeningMinutes,
  }) {
    return BluetoothDeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      leftBattery: leftBattery ?? this.leftBattery,
      rightBattery: rightBattery ?? this.rightBattery,
      caseBattery: caseBattery ?? this.caseBattery,
      isConnected: isConnected ?? this.isConnected,
      rssi: rssi ?? this.rssi,
      lastLocation: lastLocation ?? this.lastLocation,
      lastDisconnectedAt: lastDisconnectedAt ?? this.lastDisconnectedAt,
      audioCodec: audioCodec ?? this.audioCodec,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      firstPairedAt: firstPairedAt,
      totalListeningMinutes: totalListeningMinutes ?? this.totalListeningMinutes,
    );
  }
}
