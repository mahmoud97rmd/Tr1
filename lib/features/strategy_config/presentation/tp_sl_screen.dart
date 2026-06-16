import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../dashboard/providers/bot_state_provider.dart';

class TpSlScreen extends ConsumerWidget {
  const TpSlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final botState = ref.watch(botStateProvider);
    if (botState.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon));
    }

    final tpPips = botState['tp_pips'] as Map<String, dynamic>? ?? {};
    final slPips = botState['sl_pips'] as Map<String, dynamic>? ?? {};

    // Sort keys based on time
    final sortedKeys = tpPips.keys.toList()..sort((a, b) {
      final valA = _parseTf(a);
      final valB = _parseTf(b);
      return valA.compareTo(valB);
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primaryNeon),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Per-Timeframe TP/SL', style: AppTextStyles.heading2),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          final tf = sortedKeys[index];
          final tp = tpPips[tf] ?? 50;
          final sl = slPips[tf] ?? 100;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.surfaceGlass),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Timeframe: ${tf.toUpperCase()}', style: AppTextStyles.heading2.copyWith(color: AppColors.primaryNeon)),
                const SizedBox(height: 10),
                _buildSliderTile(
                  'Take Profit (Pips)',
                  tp.toDouble(),
                  10, 1000, 10,
                  (val) => ref.read(botStateProvider.notifier).updateConfig({
                    'tp_pips': {tf: val.toInt()}
                  }),
                ),
                _buildSliderTile(
                  'Stop Loss (Pips)',
                  sl.toDouble(),
                  10, 1000, 10,
                  (val) => ref.read(botStateProvider.notifier).updateConfig({
                    'sl_pips': {tf: val.toInt()}
                  }),
                ),
              ],
            ),
          ).animate().fade().slideY(begin: 0.1, delay: Duration(milliseconds: 50 * index));
        },
      ),
    );
  }

  int _parseTf(String tf) {
    if (tf.endsWith('m')) return int.tryParse(tf.replaceAll('m', '')) ?? 0;
    if (tf.endsWith('h')) return (int.tryParse(tf.replaceAll('h', '')) ?? 0) * 60;
    return 9999;
  }

  Widget _buildSliderTile(String title, double value, double min, double max, double div, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.bodyText),
            Text(value.toStringAsFixed(0), style: AppTextStyles.heading2.copyWith(color: AppColors.primaryNeon, fontSize: 16)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / div).round(),
          activeColor: AppColors.primaryNeon,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
