import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

class ProgressRing extends StatelessWidget {
  final String title;
  final double percent;
  final String centerText;
  final Color progressColor;

  const ProgressRing({
    super.key,
    required this.title,
    required this.percent,
    required this.centerText,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 60.0,
          lineWidth: 12.0,
          animation: true,
          percent: percent.clamp(0.0, 1.0),
          center: Text(
            centerText,
            style: AppTextStyles.heading2.copyWith(fontSize: 18),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: progressColor,
          backgroundColor: AppColors.surfaceDark,
        ),
        const SizedBox(height: 12),
        Text(title, style: AppTextStyles.caption),
      ],
    );
  }
}
