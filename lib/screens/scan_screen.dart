import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/bluetooth_service.dart';
import '../widgets/cyber_card.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  final BluetoothService _btService = BluetoothService();
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  String? _connectingId;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _btService.scanResults.listen((results) {
      if (mounted) setState(() => _scanResults = results);
    });

    _startScan();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _btService.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    final hasPermission = await _btService.requestPermissions();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要蓝牙和位置权限')),
        );
      }
      return;
    }

    setState(() => _isScanning = true);
    await _btService.startScan(timeout: const Duration(seconds: 15));
    if (mounted) setState(() => _isScanning = false);
  }

  Future<void> _connectToDevice(ScanResult result) async {
    setState(() => _connectingId = result.device.remoteId.str);

    final success = await _btService.connectToDevice(result.device.remoteId.str);

    if (mounted) {
      setState(() => _connectingId = null);
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('连接失败，请重试')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('扫描设备'),
        actions: [
          IconButton(
            icon: AnimatedBuilder(
              animation: _scanController,
              builder: (context, _) {
                return Transform.rotate(
                  angle: _isScanning ? _scanController.value * 2 * 3.14159 : 0,
                  child: const Icon(Icons.bluetooth_searching),
                );
              },
            ),
            onPressed: _isScanning ? null : _startScan,
          ),
        ],
      ),
      body: Column(
        children: [
          // 扫描状态
          if (_isScanning)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.primaryCyan.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryCyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('正在扫描...', style: AppTextStyles.body.copyWith(
                    color: AppColors.primaryCyan,
                  )),
                ],
              ),
            ),

          // 设备列表
          Expanded(
            child: _scanResults.isEmpty && !_isScanning
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bluetooth_disabled,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text('未发现设备', style: AppTextStyles.subHeadline.copyWith(
                          color: AppColors.textHint,
                        )),
                        const SizedBox(height: 8),
                        Text('请确保耳机处于配对模式',
                            style: AppTextStyles.bodySmall),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _startScan,
                          icon: const Icon(Icons.refresh),
                          label: const Text('重新扫描'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryCyan,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      final result = _scanResults[index];
                      final device = result.device;
                      final isConnecting = _connectingId == device.remoteId.str;

                      return CyberCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        onTap: isConnecting
                            ? null
                            : () => _connectToDevice(result),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryCyan.withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                Icons.headphones,
                                color: AppColors.primaryCyan.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.platformName.isNotEmpty
                                        ? device.platformName
                                        : '未知设备',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${device.remoteId.str} · RSSI: ${result.rssi} dBm',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (isConnecting)
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryCyan,
                                ),
                              )
                            else
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.textHint,
                                size: 16,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
