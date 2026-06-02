import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/soundscape.dart';
import '../services/audio_service.dart';
import '../widgets/cyber_card.dart';

class SoundscapeScreen extends StatefulWidget {
  const SoundscapeScreen({super.key});

  @override
  State<SoundscapeScreen> createState() => _SoundscapeScreenState();
}

class _SoundscapeScreenState extends State<SoundscapeScreen> {
  final AudioService _audioService = AudioService();
  List<Soundscape> _soundscapes = [];
  Soundscape? _playingSoundscape;
  double _volume = 0.5;
  String _selectedCategory = '全部';

  @override
  void initState() {
    super.initState();
    _loadSoundscapes();
  }

  void _loadSoundscapes() {
    final box = Hive.box<Soundscape>('soundscapes');
    if (box.isEmpty) {
      _soundscapes = Soundscape.defaults();
      for (var s in _soundscapes) {
        box.add(s);
      }
    } else {
      _soundscapes = box.values.toList();
    }
    setState(() {});
  }

  List<String> get _categories {
    final cats = <String>{'全部'};
    for (var s in _soundscapes) {
      cats.add(s.category);
    }
    return cats.toList();
  }

  List<Soundscape> get _filteredSoundscapes {
    if (_selectedCategory == '全部') return _soundscapes;
    return _soundscapes.where((s) => s.category == _selectedCategory).toList();
  }

  Future<void> _toggleSoundscape(Soundscape soundscape) async {
    if (_playingSoundscape?.id == soundscape.id) {
      await _audioService.stopSoundscape();
      setState(() => _playingSoundscape = null);
    } else {
      if (_playingSoundscape != null) {
        await _audioService.stopSoundscape();
      }
      await _audioService.playSoundscape(soundscape.id);
      await _audioService.setSoundscapeVolume(_volume);
      setState(() => _playingSoundscape = soundscape);
    }
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
              Text('MONSTER', style: AppTextStyles.label.copyWith(
                color: AppColors.accentPurple, letterSpacing: 4, fontSize: 11)),
              const SizedBox(height: 4),
              Text('声景白噪音', style: AppTextStyles.headline.copyWith(fontSize: 22)),
              const SizedBox(height: 4),
              Text('专注 · 放松 · 助眠', style: AppTextStyles.bodySmall),
              const SizedBox(height: 20),

              // 播放中状态
              if (_playingSoundscape != null) ...[
                CyberCard(
                  padding: const EdgeInsets.all(20),
                  glow: true,
                  child: Column(
                    children: [
                      Text(
                        _playingSoundscape!.icon,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _playingSoundscape!.name,
                        style: AppTextStyles.subHeadline,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '正在播放',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.successGreen,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 音量滑块
                      Row(
                        children: [
                          const Icon(Icons.volume_down,
                              color: AppColors.textHint, size: 18),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 10,
                                ),
                                activeTrackColor: AppColors.primaryCyan,
                                inactiveTrackColor: AppColors.borderGlow,
                                thumbColor: AppColors.primaryCyan,
                              ),
                              child: Slider(
                                value: _volume,
                                onChanged: (v) async {
                                  setState(() => _volume = v);
                                  await _audioService.setSoundscapeVolume(v);
                                },
                              ),
                            ),
                          ),
                          const Icon(Icons.volume_up,
                              color: AppColors.textHint, size: 18),
                        ],
                      ),

                      // 停止按钮
                      CyberButton(
                        label: '停止播放',
                        icon: Icons.stop_rounded,
                        onPressed: () => _toggleSoundscape(_playingSoundscape!),
                        isActive: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 分类筛选
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _categories.map((cat) {
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryCyan.withOpacity(0.15)
                                : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryCyan
                                  : AppColors.borderGlow.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? AppColors.primaryCyan
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // 声景网格
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: _filteredSoundscapes.length,
                itemBuilder: (context, index) {
                  final soundscape = _filteredSoundscapes[index];
                  final isPlaying = _playingSoundscape?.id == soundscape.id;

                  return GestureDetector(
                    onTap: () => _toggleSoundscape(soundscape),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isPlaying
                            ? const LinearGradient(
                                colors: [Color(0xFF1A3A4A), Color(0xFF0D2130)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF141832), Color(0xFF1A1F3D)],
                              ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isPlaying
                              ? AppColors.primaryCyan.withOpacity(0.6)
                              : AppColors.borderGlow.withOpacity(0.3),
                          width: isPlaying ? 1.5 : 1,
                        ),
                        boxShadow: isPlaying
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryCyan.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            soundscape.icon,
                            style: const TextStyle(fontSize: 36),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            soundscape.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isPlaying
                                  ? AppColors.primaryCyan
                                  : AppColors.textSecondary,
                            ),
                          ),
                          if (isPlaying)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.successGreen,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 定时器
              CyberCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: AppColors.warningOrange, size: 20),
                        const SizedBox(width: 8),
                        Text('定时关闭', style: AppTextStyles.label),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTimerButton('30分钟', 30),
                        _buildTimerButton('1小时', 60),
                        _buildTimerButton('2小时', 120),
                        _buildTimerButton('不限', 0),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerButton(String label, int minutes) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(minutes == 0
                ? '已取消定时'
                : '将在 $minutes 分钟后自动停止'),
            backgroundColor: AppColors.cardBackground,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.borderGlow.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primaryCyan,
          ),
        ),
      ),
    );
  }
}
