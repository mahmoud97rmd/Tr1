import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../providers/bot_state_provider.dart';
import 'widgets/metric_card.dart';
import 'widgets/progress_ring.dart';

class MainDashboardScreen extends ConsumerWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final botState = ref.watch(botStateProvider);
    
    if (botState.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
      );
    }

    if (botState.containsKey('error')) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.dangerRed, size: 60),
                const SizedBox(height: 20),
                Text('Connection Error', style: AppTextStyles.heading2),
                const SizedBox(height: 10),
                Text(
                  botState['error'].toString(),
                  style: AppTextStyles.caption.copyWith(color: AppColors.dangerRed),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => ref.read(botStateProvider.notifier).fetchStatus(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceDark),
                  child: const Text('Retry Connection'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isConnected = botState['live_connected'] ?? false;
    final isRunning = botState['status'] == 'RUNNING';
    final sodBalance = botState['sod_balance'] ?? 0.0;
    // Mocking current equity for UI purposes, this would come from websockets
    final currentEquity = sodBalance; 
    final ddTriggered = botState['dd_triggered'] ?? false;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Command Center', style: AppTextStyles.heading1),
            Row(
              children: [
                Icon(Icons.circle, size: 10, color: isConnected ? AppColors.successGreen : AppColors.dangerRed),
                const SizedBox(width: 5),
                Text(isConnected ? 'MetaApi Connected' : 'Disconnected', style: AppTextStyles.caption),
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill, 
              color: isRunning ? AppColors.warningGold : AppColors.successGreen, size: 32),
            onPressed: () => ref.read(botStateProvider.notifier).toggleEngine(),
          ),
          IconButton(
            icon: const Icon(Icons.sync, color: AppColors.primaryNeon),
            onPressed: () => ref.read(botStateProvider.notifier).toggleLiveConn(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'SOD Balance',
                    value: '\$${sodBalance.toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet,
                    iconColor: AppColors.primaryNeon,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: MetricCard(
                    title: 'Current Equity',
                    value: '\$${currentEquity.toStringAsFixed(2)}',
                    icon: Icons.show_chart,
                    iconColor: AppColors.successGreen,
                  ),
                ),
              ],
            ).animate().fade().slideY(begin: 0.2),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ProgressRing(
                  title: 'Drawdown Limit (3%)',
                  percent: ddTriggered ? 1.0 : 0.1, 
                  centerText: ddTriggered ? 'MAX' : 'Safe',
                  progressColor: ddTriggered ? AppColors.dangerRed : AppColors.successGreen,
                ),
                ProgressRing(
                  title: 'Daily Target',
                  percent: 0.0, 
                  centerText: '\$0',
                  progressColor: AppColors.primaryNeon,
                ),
              ],
            ).animate().fade(delay: 200.ms).scale(),
            const SizedBox(height: 40),
            // Panic Close All Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () => ref.read(botStateProvider.notifier).closeAllPositions(),
                icon: const Icon(Icons.warning_rounded, color: Colors.white),
                label: Text('PANIC CLOSE ALL', style: AppTextStyles.heading2.copyWith(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dangerRed.withOpacity(0.8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ).animate().fade(delay: 400.ms).slideY(begin: 0.5),
          ],
        ),
      ),
    );
  }
}
