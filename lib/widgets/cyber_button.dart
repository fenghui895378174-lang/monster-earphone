import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CyberButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isActive;
  final double width;

  const CyberButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isActive = false,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF00B8D4)],
                )
              : null,
          color: isActive ? null : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.primaryCyan
                : AppColors.borderGlow.withOpacity(0.4),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primaryCyan.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isActive ? Colors.black : AppColors.primaryCyan,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isActive ? Colors.black : AppColors.primaryCyan,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
