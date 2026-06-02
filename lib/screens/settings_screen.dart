import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/cyber_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box _settingsBox;

  bool _lowBatteryAlert = true;
  int _lowBatteryThreshold = 20;
  bool _autoConnect = true;
  bool _hearingProtection = true;
  int _maxVolumeLimit = 85;
  bool _vibration = true;
  String _language = '中文';

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _lowBatteryAlert = _settingsBox.get('lowBatteryAlert', defaultValue: true);
      _lowBatteryThreshold = _settingsBox.get('lowBatteryThreshold', defaultValue: 20);
      _autoConnect = _settingsBox.get('autoConnect', defaultValue: true);
      _hearingProtection = _settingsBox.get('hearingProtection', defaultValue: true);
      _maxVolumeLimit = _settingsBox.get('maxVolumeLimit', defaultValue: 85);
      _vibration = _settingsBox.get('vibration', defaultValue: true);
      _language = _settingsBox.get('language', defaultValue: '中文');
    });
  }

  void _saveSetting(String key, dynamic value) {
    _settingsBox.put(key, value);
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 连接设置
            _buildSectionTitle('连接设置'),
            CyberCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSwitchTile(
                    '自动连接',
                    '打开App时自动连接已配对设备',
                    _autoConnect,
                    (v) => _saveSetting('autoConnect', v),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    '连接振动反馈',
                    '连接成功时振动提醒',
                    _vibration,
                    (v) => _saveSetting('vibration', v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 电量设置
            _buildSectionTitle('电量提醒'),
            CyberCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSwitchTile(
                    '低电量提醒',
                    '电量低于阈值时推送通知',
                    _lowBatteryAlert,
                    (v) => _saveSetting('lowBatteryAlert', v),
                  ),
                  _buildDivider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('提醒阈值', style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      )),
                      Row(
                        children: [
                          _buildThresholdButton(10),
                          _buildThresholdButton(15),
                          _buildThresholdButton(20),
                          _buildThresholdButton(30),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 听力保护
            _buildSectionTitle('听力保护'),
            CyberCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSwitchTile(
                    '听力保护模式',
                    '限制最大音量，保护听力健康',
                    _hearingProtection,
                    (v) => _saveSetting('hearingProtection', v),
                  ),
                  _buildDivider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('最大音量限制', style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      )),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: AppColors.textHint, size: 20),
                            onPressed: () {
                              if (_maxVolumeLimit > 60) {
                                _saveSetting('maxVolumeLimit', _maxVolumeLimit - 5);
                              }
                            },
                          ),
                          Text(
                            '${_maxVolumeLimit}%',
                            style: AppTextStyles.valueDisplay.copyWith(fontSize: 14),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: AppColors.textHint, size: 20),
                            onPressed: () {
                              if (_maxVolumeLimit < 100) {
                                _saveSetting('maxVolumeLimit', _maxVolumeLimit + 5);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 通用设置
            _buildSectionTitle('通用'),
            CyberCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTapTile(
                    '语言',
                    _language,
                    () => _showLanguagePicker(),
                  ),
                  _buildDivider(),
                  _buildTapTile(
                    '清除缓存',
                    '清除听音历史和缓存数据',
                    () => _clearCache(),
                    iconColor: AppColors.errorRed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 关于
            _buildSectionTitle('关于'),
            CyberCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoTile('版本', '1.0.0'),
                  _buildDivider(),
                  _buildInfoTile('设备型号', '魔音蓝牙耳机通用版'),
                  _buildDivider(),
                  _buildInfoTile('音频引擎', 'Cyber Audio Engine v1.0'),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 重置按钮
            Center(
              child: TextButton.icon(
                onPressed: () => _resetAll(),
                icon: const Icon(Icons.restart_alt, color: AppColors.errorRed, size: 18),
                label: Text(
                  '恢复出厂设置',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.errorRed,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: AppTextStyles.label),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value,
      ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
              )),
              Text(subtitle, style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryCyan,
          activeTrackColor: AppColors.primaryCyan.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildTapTile(String title, String value, VoidCallback onTap,
      {Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.body.copyWith(
            color: iconColor ?? AppColors.textPrimary,
          )),
          Row(
            children: [
              Text(value, style: AppTextStyles.bodySmall.copyWith(
                color: iconColor ?? AppColors.textSecondary,
              )),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right,
                  color: iconColor ?? AppColors.textHint, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
        )),
        Text(value, style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        )),
      ],
    );
  }

  Widget _buildThresholdButton(int value) {
    final isSelected = _lowBatteryThreshold == value;
    return GestureDetector(
      onTap: () => _saveSetting('lowBatteryThreshold', value),
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryCyan.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryCyan
                : AppColors.borderGlow.withOpacity(0.3),
          ),
        ),
        child: Text(
          '$value%',
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? AppColors.primaryCyan : AppColors.textHint,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: AppColors.borderGlow, height: 1),
    );
  }

  void _showLanguagePicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('选择语言', style: AppTextStyles.subHeadline),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['中文', 'English'].map((lang) {
            return ListTile(
              title: Text(lang, style: TextStyle(
                color: _language == lang
                    ? AppColors.primaryCyan
                    : AppColors.textPrimary,
              )),
              trailing: _language == lang
                  ? const Icon(Icons.check, color: AppColors.primaryCyan)
                  : null,
              onTap: () {
                _saveSetting('language', lang);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('清除缓存', style: AppTextStyles.subHeadline),
        content: Text(
          '将清除所有听音历史记录和缓存数据，此操作不可恢复。',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Hive.box('listening_sessions').clear();
              Hive.box('daily_reports').clear();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('缓存已清除'),
                  backgroundColor: AppColors.cardBackground,
                ),
              );
            },
            child: const Text('确定', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

  void _resetAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('恢复出厂设置', style: AppTextStyles.subHeadline.copyWith(
          color: AppColors.errorRed,
        )),
        content: Text(
          '将清除所有设置、听音历史和配对设备信息。此操作不可恢复！',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Hive.box('settings').clear();
              Hive.box('devices').clear();
              Hive.box('listening_sessions').clear();
              Hive.box('daily_reports').clear();
              _loadSettings();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已恢复出厂设置'),
                  backgroundColor: AppColors.cardBackground,
                ),
              );
            },
            child: const Text('确定重置',
                style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}
