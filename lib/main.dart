import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'models/device_model.dart';
import 'models/eq_preset.dart';
import 'models/listening_report.dart';
import 'models/soundscape.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // 初始化 Hive
  await Hive.initFlutter();
  Hive.registerAdapter(BluetoothDeviceModelAdapter());
  Hive.registerAdapter(EQPresetAdapter());
  Hive.registerAdapter(ListeningSessionAdapter());
  Hive.registerAdapter(DailyReportAdapter());
  Hive.registerAdapter(SoundscapeAdapter());

  await Hive.openBox('settings');
  await Hive.openBox<BluetoothDeviceModel>('devices');
  await Hive.openBox<EQPreset>('eq_presets');
  await Hive.openBox<ListeningSession>('listening_sessions');
  await Hive.openBox<DailyReport>('daily_reports');
  await Hive.openBox<Soundscape>('soundscapes');

  runApp(const MonsterEarphoneApp());
}
