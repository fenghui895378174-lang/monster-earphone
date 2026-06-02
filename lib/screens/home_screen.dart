import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/bluetooth_service.dart';
import '../services/health_service.dart';
import '../models/device_model.dart';
import '../models/eq_preset.dart';
import '../widgets/cyber_card.dart';
import '../widgets/battery_indicator.dart';
import '../widgets/signal_radar.dart';
import '../widgets/eq_visualizer.dart';
import '../widgets/cyber_button.dart';
import 'scan_screen.dart';
import 'eq_screen.dart';
import 'find_screen.dart';
import 'health_screen.dart';
import 'soundscape_screen.dart';
import 'burnin_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final BluetoothService _btService = BluetoothService();
  final HealthService _healthService = HealthService();
  BluetoothDeviceModel? _device;
  EQPreset? _activePreset;
  int _currentTab = 0;

  late AnimationController _pulseController;
  late AnimationController _scanlineController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanlineController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _btService.deviceStream.listen((device) {
      if (mounted && device != null) {
        setState(() => _device = device);
        if (device.isConnected && _activePreset == null) {
          _healthService.startSession(device.id, '平坦');
          setState(() => _activePreset = EQPreset.defaultPresets().last);
        }
        if (!device.isConnected) {
          _healthService.endSession();
          setState(() => _activePreset = null);
        }
      }
    });

    _btService.rssiStream.listen((rssi) {
      if (mounted && _device != null) {
        setState(() => _device = _device!.copyWith(rssi: rssi));
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanlineController.dispose();
    _btService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Stack(
          children: [
            // 背景
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.gradientDark,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // 扫描线动画背景
            AnimatedBuilder(
              animation: _scanlineController,
              builder: (context, _) {
                return Positioned(
                  top: _scanlineController.value * MediaQuery.of(context).size.height,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.primaryCyan.withOpacity(0.1),
                          AppColors.primaryCyan.withOpacity(0.3),
                          AppColors.primaryCyan.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // 网格背景
            CustomPaint(
              painter: _GridPainter(),
              size: Size.infinite,
            ),

            // 主内容
            SafeArea(
              child: IndexedStack(
                index: _currentTab,
                children: [
                  _buildDashboard(),
                  const EQScreen(),
                  const FindScreen(),
                  const HealthScreen(),
                  const SoundscapeScreen(),
                ],
              ),
            ),
          ],
        ),
      ),

      // 底部导航
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bottomNavBg,
          border: Border(
            top: BorderSide(
              color: AppColors.primaryCyan.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (index) => setState(() => _currentTab = index),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: '仪表盘',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.equalizer_rounded),
              label: '均衡器',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.my_location_rounded),
              label: '查找',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded),
              label: '健康',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.spa_rounded),
              label: '声景',
            ),
          ],
        ),
      ),

      // 浮动按钮
      floatingActionButton: _device?.isConnected != true
          ? AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryCyan.withOpacity(
                          0.3 + 0.2 * _pulseController.value,
                        ),
                        blurRadius: 20 + 10 * _pulseController.value,
                        spreadRadius: 5 * _pulseController.value,
                      ),
                    ],
                  ),
                  child: FloatingActionButton.extended(
                    onPressed: () => _navigateToScan(),
                    backgroundColor: AppColors.primaryCyan,
                    foregroundColor: Colors.black,
                    icon: const Icon(Icons.bluetooth_searching),
                    label: const Text('连接耳机', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题栏
          _buildHeader(),
          const SizedBox(height: 16),

          // 设备状态
          if (_device?.isConnected == true) ...[
            _buildConnectedDashboard(),
          ] else ...[
            _buildDisconnectedState(),
          ],

          const SizedBox(height: 100), // 给 FAB 留空间
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MONSTER', style: AppTextStyles.label.copyWith(
              color: AppColors.accentPurple,
              letterSpacing: 4,
              fontSize: 11,
            )),
            const SizedBox(height: 4),
            Text('CYBER CONSOLE', style: AppTextStyles.headline.copyWith(fontSize: 22)),
          ],
        ),
        Row(
          children: [
            _buildStatusDot(_device?.isConnected == true),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusDot(bool connected) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: connected ? AppColors.successGreen : AppColors.errorRed,
        boxShadow: [
          BoxShadow(
            color: (connected ? AppColors.successGreen : AppColors.errorRed).withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedDashboard() {
    return Column(
      children: [
        // 电池电量区
        CyberCard(
          padding: const EdgeInsets.all(20),
          glow: true,
          child: Column(
            children: [
              Text('电量状态', style: AppTextStyles.label),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BatteryIndicator(
                    percentage: _device!.leftBattery,
                    label: 'L',
                  ),
                  BatteryIndicator(
                    percentage: _device!.rightBattery,
                    label: 'R',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 充电盒电量
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.battery_charging_full_rounded,
                      color: AppColors.warningOrange, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '充电盒 ${_device!.caseBattery}%',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.warningOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 电量进度条
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _device!.caseBattery / 100,
                  backgroundColor: AppColors.borderGlow,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _device!.caseBattery > 30
                        ? AppColors.warningOrange
                        : AppColors.errorRed,
                  ),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 信号强度 + 编码格式
        Row(
          children: [
            Expanded(
              child: CyberCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('信号强度', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    SignalRadar(rssi: _device!.rssi),
                    const SizedBox(height: 8),
                    Text(
                      '${_device!.rssi} dBm · ${_device!.rssiLabel}',
                      style: AppTextStyles.valueDisplay.copyWith(
                        color: _device!.rssiColor(),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CyberCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('音频编码', style: AppTextStyles.label),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _device!.audioCodec ?? 'AAC',
                        style: AppTextStyles.valueDisplay.copyWith(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '固件 v${_device!.firmwareVersion ?? "1.0.0"}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // EQ 可视化
        CyberCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('EQ 波形', style: AppTextStyles.label),
                  Text(
                    _activePreset?.name ?? '平坦',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryCyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              EQVisualizer(
                bands: _activePreset?.bands ?? List.filled(10, 0.0),
                height: 100,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 快捷操作
        Row(
          children: [
            Expanded(
              child: CyberButton(
                label: '均衡器',
                icon: Icons.equalizer_rounded,
                onPressed: () => setState(() => _currentTab = 1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CyberButton(
                label: '查找耳机',
                icon: Icons.my_location_rounded,
                onPressed: () => setState(() => _currentTab = 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CyberButton(
                label: '听力报告',
                icon: Icons.favorite_border_rounded,
                onPressed: () => setState(() => _currentTab = 3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CyberButton(
                label: '煲机助手',
                icon: Icons.headphones_rounded,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BurnInScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisconnectedState() {
    return Column(
      children: [
        const SizedBox(height: 60),
        // 未连接状态的赛博动画
        Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: _DisconnectedPainter(
                pulseValue: _pulseController.value,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '未连接设备',
          style: AppTextStyles.subHeadline.copyWith(
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '点击下方按钮连接你的魔音耳机',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 32),

        // 快捷功能(即使未连接也可用)
        CyberCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('离线功能', style: AppTextStyles.label),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CyberButton(
                      label: '白噪音',
                      icon: Icons.spa_rounded,
                      onPressed: () => setState(() => _currentTab = 4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CyberButton(
                      label: '煲机助手',
                      icon: Icons.headphones_rounded,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BurnInScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CyberButton(
                      label: '设备管理',
                      icon: Icons.devices_rounded,
                      onPressed: _navigateToScan,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CyberButton(
                      label: '设置',
                      icon: Icons.settings_outlined,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToScan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
  }
}

// 网格背景画笔
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryCyan.withOpacity(0.03)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 未连接状态动画画笔
class _DisconnectedPainter extends CustomPainter {
  final double pulseValue;

  _DisconnectedPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // 外圈脉冲
    for (int i = 0; i < 3; i++) {
      final pulseRadius = radius + i * 20 * pulseValue;
      final opacity = (1 - pulseValue) * (1 - i * 0.3);
      final paint = Paint()
        ..color = AppColors.primaryCyan.withOpacity(opacity * 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, pulseRadius, paint);
    }

    // 中心耳机图标
    final iconPaint = Paint()
      ..color = AppColors.primaryCyan.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // 简化耳机图标
    final bandPath = Path()
      ..addArc(Rect.fromCircle(center: Offset(center.dx - 25, center.dy - 10), radius: 20),
          pi * 1.2, pi * 1.6)
      ..lineTo(center.dx + 5, center.dy + 25)
      ..lineTo(center.dx + 15, center.dy + 25)
      ..addArc(Rect.fromCircle(center: Offset(center.dx + 25, center.dy - 10), radius: 20),
          pi * 1.4, pi * 1.6);

    canvas.drawPath(bandPath, iconPaint);

    // 底部文字提示脉冲
    final textPaint = Paint()
      ..color = AppColors.primaryCyan.withOpacity(0.3 + 0.2 * pulseValue)
      ..style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant _DisconnectedPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}
