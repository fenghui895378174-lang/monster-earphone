import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/eq_preset.dart';
import '../widgets/cyber_card.dart';
import '../widgets/eq_visualizer.dart';

class EQScreen extends StatefulWidget {
  const EQScreen({super.key});

  @override
  State<EQScreen> createState() => _EQScreenState();
}

class _EQScreenState extends State<EQScreen> {
  List<EQPreset> _presets = [];
  EQPreset? _activePreset;
  int _selectedBand = 0;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  void _loadPresets() {
    final box = Hive.box<EQPreset>('eq_presets');
    if (box.isEmpty) {
      _presets = EQPreset.defaultPresets();
      for (var p in _presets) {
        box.add(p);
      }
    } else {
      _presets = box.values.toList();
    }
    setState(() {});
  }

  void _activatePreset(EQPreset preset) {
    setState(() {
      for (var p in _presets) {
        p.isActive = false;
      }
      preset.isActive = true;
      _activePreset = preset;
    });
    // 保存
    final box = Hive.box<EQPreset>('eq_presets');
    for (int i = 0; i < _presets.length; i++) {
      box.putAt(i, _presets[i]);
    }
  }

  void _adjustBand(int bandIndex, double value) {
    if (_activePreset == null) return;
    final newBands = List<double>.from(_activePreset!.bands);
    newBands[bandIndex] = value.clamp(-6.0, 6.0);
    setState(() {
      _activePreset!.bands = newBands;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text('MONSTER', style: AppTextStyles.label.copyWith(
                color: AppColors.accentPurple,
                letterSpacing: 4,
                fontSize: 11,
              )),
              const SizedBox(height: 4),
              Text('均衡器', style: AppTextStyles.headline.copyWith(fontSize: 22)),
              const SizedBox(height: 20),

              // EQ 可视化
              CyberCard(
                padding: const EdgeInsets.all(20),
                glow: _activePreset != null,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('实时波形', style: AppTextStyles.label),
                        if (_activePreset != null)
                          Text(
                            '${_activePreset!.icon} ${_activePreset!.name}',
                            style: AppTextStyles.valueDisplay.copyWith(fontSize: 14),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    EQVisualizer(
                      bands: _activePreset?.bands ?? List.filled(10, 0.0),
                      height: 140,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 频段滑块
              if (_activePreset != null) ...[
                CyberCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('频段调节', style: AppTextStyles.label),
                          Text(
                            '${EQPreset.frequencies[_selectedBand]} Hz',
                            style: AppTextStyles.valueDisplay.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('-6', style: AppTextStyles.bodySmall),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 12,
                                ),
                                activeTrackColor: AppColors.primaryCyan,
                                inactiveTrackColor: AppColors.borderGlow,
                                thumbColor: AppColors.primaryCyan,
                                overlayColor: AppColors.primaryCyan.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: _activePreset!.bands[_selectedBand],
                                min: -6,
                                max: 6,
                                divisions: 24,
                                onChanged: (v) => _adjustBand(_selectedBand, v),
                              ),
                            ),
                          ),
                          Text('+6', style: AppTextStyles.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          '${_activePreset!.bands[_selectedBand].toStringAsFixed(1)} dB',
                          style: AppTextStyles.valueDisplay.copyWith(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 频段快捷选择
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(10, (i) {
                          final freq = EQPreset.frequencies[i];
                          final label = freq >= 1000
                              ? '${freq ~/ 1000}K'
                              : '$freq';
                          return GestureDetector(
                            onTap: () => setState(() => _selectedBand = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _selectedBand == i
                                    ? AppColors.primaryCyan.withOpacity(0.2)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _selectedBand == i
                                      ? AppColors.primaryCyan
                                      : AppColors.borderGlow.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _selectedBand == i
                                      ? AppColors.primaryCyan
                                      : AppColors.textHint,
                                  fontWeight: _selectedBand == i
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 预设列表
              Text('预设场景', style: AppTextStyles.label),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemCount: _presets.length,
                itemBuilder: (context, index) {
                  final preset = _presets[index];
                  final isActive = preset.isActive;
                  return GestureDetector(
                    onTap: () => _activatePreset(preset),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? const LinearGradient(
                                colors: [Color(0xFF00E5FF), Color(0xFF00B8D4)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF141832), Color(0xFF1A1F3D)],
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primaryCyan
                              : AppColors.borderGlow.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(preset.icon, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 8),
                          Text(
                            preset.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.black
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 3D环绕和低音增强
              Row(
                children: [
                  Expanded(
                    child: _buildToggleCard(
                      icon: Icons.surround_sound_rounded,
                      title: '3D 环绕',
                      subtitle: '虚拟空间音效',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildToggleCard(
                      icon: Icons.speaker_group_rounded,
                      title: '低音增强',
                      subtitle: 'Bass Boost',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return CyberCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryCyan, size: 28),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.label.copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}
