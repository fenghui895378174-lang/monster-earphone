import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/health_service.dart';
import '../models/listening_report.dart';
import '../widgets/cyber_card.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final HealthService _healthService = HealthService();
  late Map<String, dynamic> _stats;
  List<DailyReport> _weeklyReports = [];
  List<DailyReport> _monthlyReports = [];
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _stats = _healthService.getStats();
    _weeklyReports = _healthService.getWeeklyReports();
    _monthlyReports = _healthService.getMonthlyReports();
    setState(() {});
  }

  List<DailyReport> get _currentReports =>
      _selectedPeriod == 'week' ? _weeklyReports : _monthlyReports;

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
              Text('听力健康', style: AppTextStyles.headline.copyWith(fontSize: 22)),
              const SizedBox(height: 20),

              // 统计卡片
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '总听音时长',
                      '${_stats['totalHours']} 小时',
                      Icons.headphones_rounded,
                      AppColors.primaryCyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '日均音量',
                      '${(_stats['avgDailyVolume'] as num).toStringAsFixed(0)} dB',
                      Icons.volume_up_rounded,
                      AppColors.accentPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '总听音次数',
                      '${_stats['totalSessions']} 次',
                      Icons.music_note_rounded,
                      AppColors.successGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '高风险天数',
                      '${_stats['highRiskDays']} 天',
                      Icons.warning_rounded,
                      AppColors.errorRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 周期切换
              Row(
                children: [
                  Text('听音趋势', style: AppTextStyles.label),
                  const Spacer(),
                  _buildPeriodButton('week', '近7天'),
                  const SizedBox(width: 8),
                  _buildPeriodButton('month', '近30天'),
                ],
              ),
              const SizedBox(height: 12),

              // 图表
              CyberCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: _currentReports.isEmpty
                          ? Center(
                              child: Text('暂无数据',
                                  style: AppTextStyles.bodySmall),
                            )
                          : BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 180,
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      final report = _currentReports[groupIndex];
                                      return BarTooltipItem(
                                        '${report.totalMinutes}分钟\n${report.avgVolume.toStringAsFixed(0)}dB',
                                        TextStyle(
                                          color: AppColors.primaryCyan,
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final idx = value.toInt();
                                        if (idx >= 0 && idx < _currentReports.length) {
                                          final d = _currentReports[idx].date;
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              '${d.month}/${d.day}',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                fontSize: 9,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 35,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${value.toInt()}m',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            fontSize: 9,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 60,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: AppColors.borderGlow.withOpacity(0.3),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: _currentReports.asMap().entries.map((e) {
                                  final report = e.value;
                                  final isRisk = report.riskLevel == '高风险';
                                  return BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: report.totalMinutes.toDouble(),
                                        color: isRisk
                                            ? AppColors.errorRed
                                            : AppColors.primaryCyan,
                                        width: _selectedPeriod == 'week' ? 24 : 8,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '每日听音时长 (分钟)',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // WHO 标准对比
              CyberCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.health_and_safety_outlined,
                            color: AppColors.successGreen, size: 20),
                        const SizedBox(width: 8),
                        Text('WHO 听力安全标准', style: AppTextStyles.label),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildWHOGuideline(
                      '安全区域',
                      '< 70 dB · < 120分钟/天',
                      AppColors.successGreen,
                    ),
                    _buildWHOGuideline(
                      '注意区域',
                      '70-85 dB · 120-180分钟/天',
                      AppColors.warningOrange,
                    ),
                    _buildWHOGuideline(
                      '危险区域',
                      '> 85 dB · > 180分钟/天',
                      AppColors.errorRed,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 听音建议
              CyberCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tips_and_updates_outlined,
                            color: AppColors.warningOrange, size: 20),
                        const SizedBox(width: 8),
                        Text('健康建议', style: AppTextStyles.label),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildAdvice('🔇', '遵循 60/60 法则：音量不超过60%，每次不超过60分钟'),
                    _buildAdvice('⏰', '每听音1小时，休息5-10分钟'),
                    _buildAdvice('🎧', '嘈杂环境中尽量使用降噪功能，而非调高音量'),
                    _buildAdvice('📊', '每周查看听音报告，关注高风险天数'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return CyberCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 22),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.valueDisplay.copyWith(
            color: color,
            fontSize: 18,
          )),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryCyan.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryCyan : AppColors.borderGlow.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppColors.primaryCyan : AppColors.textHint,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildWHOGuideline(String title, String detail, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.3),
              border: Border.all(color: color, width: 2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                )),
                Text(detail, style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvice(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
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
