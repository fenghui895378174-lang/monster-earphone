import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/listening_report.dart';

/// 听力健康服务：记录听音数据，生成健康报告
class HealthService {
  static final HealthService _instance = HealthService._();
  factory HealthService() => _instance;
  HealthService._();

  final Random _random = Random();
  ListeningSession? _currentSession;

  // 开始记录听音会话
  void startSession(String deviceId, String eqPreset) {
    _currentSession = ListeningSession(
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      averageVolume: 60 + _random.nextDouble() * 20,
      peakVolume: 75 + _random.nextDouble() * 20,
      eqPresetUsed: eqPreset,
      deviceId: deviceId,
    );
  }

  // 结束听音会话
  Future<void> endSession() async {
    if (_currentSession == null) return;
    _currentSession!.endTime = DateTime.now();

    final box = Hive.box<ListeningSession>('listening_sessions');
    await box.add(_currentSession!);

    // 更新日报
    await _updateDailyReport();

    _currentSession = null;
  }

  // 更新每日报告
  Future<void> _updateDailyReport() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final sessionsBox = Hive.box<ListeningSession>('listening_sessions');

    final todaySessions = sessionsBox.values.where((s) {
      final d = s.startTime;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).toList();

    final totalMinutes = todaySessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final avgVol = todaySessions.isEmpty
        ? 0.0
        : todaySessions.map((s) => s.averageVolume).reduce((a, b) => a + b) /
            todaySessions.length;

    String risk = '安全';
    if (avgVol > 85 && totalMinutes > 60) {
      risk = '高风险';
    } else if (avgVol > 75 && totalMinutes > 120) {
      risk = '中风险';
    } else if (avgVol > 70 || totalMinutes > 180) {
      risk = '低风险';
    }

    final report = DailyReport(
      date: todayDate,
      totalMinutes: totalMinutes,
      avgVolume: avgVol,
      sessionCount: todaySessions.length,
      riskLevel: risk,
    );

    final reportBox = Hive.box<DailyReport>('daily_reports');
    // 更新或添加
    final existing = reportBox.values.where((r) {
      final d = r.date;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).toList();

    if (existing.isNotEmpty) {
      final idx = reportBox.values.toList().indexOf(existing.first);
      await reportBox.putAt(idx, report);
    } else {
      await reportBox.add(report);
    }
  }

  // 获取周报
  List<DailyReport> getWeeklyReports() {
    final reportBox = Hive.box<DailyReport>('daily_reports');
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return reportBox.values.where((r) {
      return r.date.isAfter(weekAgo) && r.date.isBefore(now.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // 获取月报
  List<DailyReport> getMonthlyReports() {
    final reportBox = Hive.box<DailyReport>('daily_reports');
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    return reportBox.values.where((r) {
      return r.date.isAfter(monthAgo) && r.date.isBefore(now.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // 获取听音历史统计
  Map<String, dynamic> getStats() {
    final reportBox = Hive.box<DailyReport>('daily_reports');
    final reports = reportBox.values.toList();

    if (reports.isEmpty) {
      return {
        'totalHours': 0,
        'avgDailyVolume': 0.0,
        'highRiskDays': 0,
        'totalSessions': 0,
      };
    }

    return {
      'totalHours': reports.fold<int>(0, (s, r) => s + r.totalMinutes) ~/ 60,
      'avgDailyVolume': reports.map((r) => r.avgVolume).reduce((a, b) => a + b) /
          reports.length,
      'highRiskDays': reports.where((r) => r.riskLevel == '高风险').length,
      'totalSessions': reports.fold<int>(0, (s, r) => s + r.sessionCount),
    };
  }
}
