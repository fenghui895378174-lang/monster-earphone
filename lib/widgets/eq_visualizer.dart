import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EQVisualizer extends StatefulWidget {
  final List<double> bands;
  final double height;
  final bool animated;

  const EQVisualizer({
    super.key,
    required this.bands,
    this.height = 120,
    this.animated = true,
  });

  @override
  State<EQVisualizer> createState() => _EQVisualizerState();
}

class _EQVisualizerState extends State<EQVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animated) {
      return SizedBox(
        height: widget.height,
        child: CustomPaint(
          painter: _EQPainter(bands: widget.bands, animValue: 1.0),
          size: Size.infinite,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: CustomPaint(
            painter: _EQPainter(
              bands: widget.bands,
              animValue: _controller.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _EQPainter extends CustomPainter {
  final List<double> bands;
  final double animValue;

  _EQPainter({required this.bands, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (bands.isEmpty) return;

    final barWidth = size.width / bands.length - 2;
    final centerY = size.height / 2;

    for (int i = 0; i < bands.length; i++) {
      // 归一化 band 值 (-6 到 +6 映射到高度)
      final normalizedValue = (bands[i] + 6) / 12;
      final barHeight = normalizedValue * size.height * 0.45;
      final animHeight = barHeight * (0.6 + 0.4 * animValue);
      final x = i * (barWidth + 2) + 1;

      // 渐变色
      final t = i / bands.length;
      final color = Color.lerp(
        AppColors.primaryCyan,
        AppColors.accentPurple,
        t,
      )!;

      // 上半部分 (正值)
      final topRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, centerY - animHeight, barWidth, animHeight),
        const Radius.circular(2),
      );
      final topPaint = Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(Rect.fromLTWH(x, centerY - animHeight, barWidth, animHeight));

      canvas.drawRRect(topRect, topPaint);

      // 下半部分 (负值, 如果有)
      if (bands[i] < 0) {
        final bottomHeight = barHeight * 0.3;
        final bottomRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, centerY, barWidth, bottomHeight),
          const Radius.circular(2),
        );
        final bottomPaint = Paint()
          ..color = color.withOpacity(0.3);

        canvas.drawRRect(bottomRect, bottomPaint);
      }

      // 发光效果
      final glowPaint = Paint()
        ..color = color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawLine(
        Offset(x + barWidth / 2, centerY - animHeight),
        Offset(x + barWidth / 2, centerY - animHeight + 4),
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EQPainter oldDelegate) {
    return oldDelegate.bands != bands || oldDelegate.animValue != animValue;
  }
}
