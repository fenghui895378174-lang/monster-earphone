import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/bluetooth_service.dart';
import '../widgets/cyber_card.dart';
import '../widgets/signal_radar.dart';

class FindScreen extends StatefulWidget {
  const FindScreen({super.key});

  @override
  State<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> with SingleTickerProviderStateMixin {
  final BluetoothService _btService = BluetoothService();
  int _rssi = -50;
  bool _isBuzzing = false;
  String? _lastLocation;
  String? _lastDisconnectedTime;

  late AnimationController _buzzController;

  @override
  void initState() {
    super.initState();
    _buzzController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _btService.rssiStream.listen((rssi) {
      if (mounted) setState(() => _rssi = rssi);
    });

    _btService.deviceStream.listen((device) {
      if (mounted && device != null) {
        setState(() {
          _rssi = device.rssi;
          _lastLocation = device.lastLocation;
          _lastDisconnectedTime = device.lastDisconnectedAt
              ?.toString()
              .substring(0, 19);
        });
      }
    });
  }

  @override
  void dispose() {
    _buzzController.dispose();
    super.dispose();
  }

  Future<void> _toggleBuzz() async {
    if (_isBuzzing) {
      await _btService.stopAlert();
      _buzzController.stop();
      setState(() => _isBuzzing = false);
    } else {
      await _btService.findEarphone();
      _buzzController.repeat(reverse: true);
      setState(() => _isBuzzing = true);
      // 自动停止
      Future.delayed(const Duration(seconds: 10), () async {
        if (mounted && _isBuzzing) {
          await _toggleBuzz();
        }
      });
    }
  }

  String get _distanceHint {
    if (_rssi > -45) return '很近 (< 1米)';
    if (_rssi > -60) return '较近 (1-3米)';
    if (_rssi > -75) return '中等 (3-8米)';
    if (_rssi > -90) return '较远 (8-15米)';
    return '很远 (> 15米)';
  }

  Color get _distanceColor {
    if (_rssi > -45) return AppColors.successGreen;
    if (_rssi > -60) return AppColors.primaryCyan;
    if (_rssi > -75) return AppColors.warningOrange;
    return AppColors.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _btService.currentDevice?.isConnected == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MONSTER', style: AppTextStyles.label.copyWith(
                color: AppColors.accentPurple, letterSpacing: 4, fontSize: 11)),
              const SizedBox(height: 4),
              Text('查找耳机', style: AppTextStyles.headline.copyWith(fontSize: 22)),
              const SizedBox(height: 20),

              // 信号雷达
              Center(
                child: CyberCard(
                  padding: const EdgeInsets.all(24),
                  glow: isConnected,
                  child: Column(
                    children: [
                      Text(
                        isConnected ? '已连接' : '已断开',
                        style: AppTextStyles.label.copyWith(
                          color: isConnected ? AppColors.successGreen : AppColors.errorRed,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SignalRadar(rssi: _rssi, size: 180),
                      const SizedBox(height: 16),
                      Text(
                        '${_rssi} dBm',
                        style: AppTextStyles.batteryPercent.copyWith(
                          color: _distanceColor,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _distanceColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _distanceColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _distanceHint,
                          style: TextStyle(
                            color: _distanceColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 蜂鸣按钮
              Center(
                child: GestureDetector(
                  onTap: isConnected ? _toggleBuzz : null,
                  child: AnimatedBuilder(
                    animation: _buzzController,
                    builder: (context, _) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _isBuzzing
                                ? [AppColors.accentPink, Colors.deepOrange]
                                : [AppColors.primaryCyan, AppColors.primaryCyanDark],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isBuzzing
                                      ? AppColors.accentPink
                                      : AppColors.primaryCyan)
                                  .withOpacity(0.4 + 0.3 * _buzzController.value),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isBuzzing ? Icons.volume_up : Icons.volume_up_outlined,
                          color: Colors.white,
                          size: 36,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _isBuzzing ? '点击停止蜂鸣' : '点击让耳机发声',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              const SizedBox(height: 24),

              // 信号强度条
              CyberCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('信号强度指示', style: AppTextStyles.label),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ((_rssi + 100) / 70).clamp(0.0, 1.0),
                        backgroundColor: AppColors.borderGlow,
                        valueColor: AlwaysStoppedAnimation(_distanceColor),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('弱', style: AppTextStyles.bodySmall),
                        Text('强', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 最后位置
              CyberCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: AppColors.accentPurple, size: 20),
                        const SizedBox(width: 8),
                        Text('最后断开位置', style: AppTextStyles.label),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastLocation ?? '暂无记录',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_lastDisconnectedTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '断开时间: $_lastDisconnectedTime',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 查找技巧
              CyberCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: AppColors.warningOrange, size: 20),
                        const SizedBox(width: 8),
                        Text('查找技巧', style: AppTextStyles.label),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('1', '点击蜂鸣按钮让耳机发出声音'),
                    _buildTip('2', '移动手机观察信号变化，信号越强越近'),
                    _buildTip('3', '信号 > -45dBm 时耳机就在附近'),
                    _buildTip('4', '断开连接后自动记录GPS位置'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(num, style: TextStyle(
                fontSize: 11,
                color: AppColors.primaryCyan,
                fontWeight: FontWeight.bold,
              )),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            )),
          ),
        ],
      ),
    );
  }
}
