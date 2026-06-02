import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool glow;

  const CyberCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.width,
    this.height,
    this.gradient,
    this.onTap,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          gradient: gradient ??
              const LinearGradient(
                colors: [Color(0xFF141832), Color(0xFF1A1F3D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: glow
                ? AppColors.primaryCyan.withOpacity(0.4)
                : AppColors.borderGlow.withOpacity(0.3),
            width: glow ? 1.5 : 1,
          ),
          boxShadow: glow
              ? [
                  BoxShadow(
                    color: AppColors.primaryCyan.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: child,
      ),
    );
  }
}
