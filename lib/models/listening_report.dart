import 'package:hive/hive.dart';

part 'listening_report.g.dart';

@HiveType(typeId: 2)
class ListeningSession extends HiveObject {
  @HiveField(0)
  DateTime startTime;

  @HiveField(1)
  DateTime endTime;

  @HiveField(2)
  double averageVolume;

  @HiveField(3)
  double peakVolume;

  @HiveField(4)
  String eqPresetUsed;

  @HiveField(5)
  String deviceId;

  ListeningSession({
    required this.startTime,
    required this.endTime,
    required this.averageVolume,
    required this.peakVolume,
    required this.eqPresetUsed,
    required this.deviceId,
  });

  int get durationMinutes => endTime.difference(startTime).inMinutes;

  String get riskLevel {
    if (averageVolume > 85 && durationMinutes > 60) return '高风险';
    if (averageVolume > 75 && durationMinutes > 120) return '中风险';
    if (averageVolume > 70 || durationMinutes > 180) return '低风险';
    return '安全';
  }
}

@HiveType(typeId: 3)
class DailyReport extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int totalMinutes;

  @HiveField(2)
  double avgVolume;

  @HiveField(3)
  int sessionCount;

  @HiveField(4)
  String riskLevel;

  DailyReport({
    required this.date,
    this.totalMinutes = 0,
    this.avgVolume = 0,
    this.sessionCount = 0,
    this.riskLevel = '安全',
  });

  String get whoGuideline {
    if (avgVolume <= 60 && totalMinutes <= 60) return '✅ 符合WHO标准';
    if (avgVolume <= 75 && totalMinutes <= 120) return '⚠️ 接近WHO上限';
    return '❌ 超过WHO建议';
  }
}
