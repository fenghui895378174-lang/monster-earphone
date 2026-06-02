import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/audio_service.dart';
import '../widgets/cyber_card.dart';
import '../widgets/cyber_button.dart';

class BurnInScreen extends StatefulWidget {
  const BurnInScreen({super.key});

  @override
  State<BurnInScreen> createState() => _BurnInScreenState();
}

class _BurnInScreenState extends State<BurnInScreen> with SingleTickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  late AnimationController _progressController;

  int _selectedPhase = 0;
  int _totalMinutes = 0;
  int _elapsedMinutes = 0;
  bool _isRunning = false;

  final List<Map<String, dynamic>> _phases = [
    {'name': '白噪音热身', 'icon': '📡', 'minutes': 120, 'desc': '使用白噪音让振膜初步活动'},
    {'name': '粉红噪音煲机', 'icon': '🌸', 'minutes': 240, 'desc': '粉红噪音覆盖全频段，均匀煲机'},
    {'name': '频率扫描', 'icon': '📊', 'minutes': 120, 'desc': '从低频到高频循环扫描'},
    {'name': '音乐播放', 'icon': '🎵', 'minutes': 240, 'desc': '使用精选煲机音乐'},
    {'name': '自然冷却', 'icon': '❄️', 'minutes': 60, 'desc': '停止播放，让耳机休息'},
  ];

  @override
  void initState() {
    super.initState();
    _totalMinutes = _phases.fold(0, (sum, p) => sum + (p['minutes'] as int));
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _toggleBurnIn() {
    if (_isRunning) {
      _audioService.stopBurnIn();
      _progressController.stop();
      setState(() => _isRunning = false);
    } else {
      _audioService.startBurnIn();
      _progressController.repeat();
      setState(() => _isRunning = true);
      _startSimulation();
    }
  }

  void _startSimulation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3)); // 模拟加速
      if (!_isRunning || !mounted) return false;

      setState(() {
        _elapsedMinutes += 1;
        if (_elapsedMinutes >= _totalMinutes) {
          _elapsedMinutes = _totalMinutes;
          _isRunning = false;
          _progressController.stop();
        }

        // 更新阶段
        int accumulated = 0;
        for (int i = 0; i < _phases.length; i++) {
          accumulated += _phases[i]['minutes'] as int;
          if (_elapsedMinutes < accumulated) {
            _selectedPhase = i;
            break;
          }
        }
      });
      return _isRunning && _elapsedMinutes < _totalMinutes;
    });
  }

  double get _progress => _totalMinutes > 0 ? _elapsedMinutes / _totalMinutes : 0;

  String get _remainingTime {
    final remaining = _totalMinutes - _elapsedMinutes;
    final hours = remaining ~/ 60;
    final mins = remaining % 60;
    return '${hours}小时${mins}分钟';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('煲机助手'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 煲机说明
            CyberCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.primaryCyan, size: 20),
                      const SizedBox(width: 8),
                      Text('煲机说明', style: AppTextStyles.label),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '新耳机需要经过一定时间的煲机才能达到最佳音质。'
                    '煲机助手会自动按科学流程为你的耳机进行煲机，'
                    '全程约${_totalMinutes ~/ 60}小时。',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 进度圈
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 8,
                        backgroundColor: AppColors.borderGlow.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isRunning
                              ? AppColors.primaryCyan
                              : AppColors.successGreen,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(_progress * 100).toStringAsFixed(1)}%',
                          style: AppTextStyles.batteryPercent.copyWith(
                            color: _isRunning
                                ? AppColors.primaryCyan
                                : AppColors.successGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isRunning ? '煲机中...' : '已完成',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _isRunning
                                ? AppColors.primaryCyan
                                : AppColors.successGreen,
                          ),
                        ),
                        if (_isRunning) ...[
                          const SizedBox(height: 4),
                          Text(
                            '剩余 $_remainingTime',
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 当前阶段
            CyberCard(
              padding: const EdgeInsets.all(16),
              glow: _isRunning,
              child: Row(
                children: [
                  Text(
                    _phases[_selectedPhase]['icon'] as String,
                    style: const TextStyle(fontSize: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '当前阶段',
                          style: AppTextStyles.label.copyWith(fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _phases[_selectedPhase]['name'] as String,
                          style: AppTextStyles.subHeadline.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _phases[_selectedPhase]['desc'] as String,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 所有阶段列表
            Text('煲机流程', style: AppTextStyles.label),
            const SizedBox(height: 8),
            ..._phases.asMap().entries.map((e) {
              final idx = e.key;
              final phase = e.value;
              final isCurrent = idx == _selectedPhase;
              final isDone = idx < _selectedPhase ||
                  (_elapsedMinutes >= _totalMinutes && _totalMinutes > 0);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: CyberCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? AppColors.successGreen.withOpacity(0.2)
                              : isCurrent
                                  ? AppColors.primaryCyan.withOpacity(0.2)
                                  : Colors.transparent,
                          border: Border.all(
                            color: isDone
                                ? AppColors.successGreen
                                : isCurrent
                                    ? AppColors.primaryCyan
                                    : AppColors.borderGlow.withOpacity(0.3),
                          ),
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check, color: AppColors.successGreen, size: 16)
                              : isCurrent
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryCyan,
                                      ),
                                    )
                                  : Text('${idx + 1}',
                                      style: TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 12,
                                      )),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${phase['icon']} ${phase['name']}',
                              style: AppTextStyles.body.copyWith(
                                color: isCurrent
                                    ? AppColors.primaryCyan
                                    : AppColors.textPrimary,
                                fontWeight:
                                    isCurrent ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${phase['minutes']} 分钟',
                              style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            // 开始/停止按钮
            Center(
              child: CyberButton(
                label: _isRunning ? '停止煲机' : '开始煲机',
                icon: _isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                onPressed: _toggleBurnIn,
                isActive: _isRunning,
                width: 200,
              ),
            ),

            const SizedBox(height: 12),

            // 注意事项
            Center(
              child: Text(
                '⚠️ 煲机时请将音量设置在 30-50%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.warningOrange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
