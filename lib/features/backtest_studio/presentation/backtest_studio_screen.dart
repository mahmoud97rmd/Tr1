import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/api/ws_client.dart';

class BacktestStudioScreen extends ConsumerStatefulWidget {
  const BacktestStudioScreen({super.key});

  @override
  ConsumerState<BacktestStudioScreen> createState() => _BacktestStudioScreenState();
}

class _BacktestStudioScreenState extends ConsumerState<BacktestStudioScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    ref.read(wsClientProvider).connect();
  }

  @override
  Widget build(BuildContext context) {
    final wsStream = ref.watch(wsClientProvider).stream;

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
        title: Text('Backtest Studio 3D', style: AppTextStyles.heading2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDatePicker(context),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRunning ? null : () => setState(() => _isRunning = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNeon,
                padding: const EdgeInsets.all(15),
              ),
              child: Text('Run Triple-Engine Backtest', style: AppTextStyles.bodyText.copyWith(color: AppColors.backgroundDark)),
            ),
            const SizedBox(height: 40),
            if (_isRunning) _buildProgressListener(wsStream),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text('Start Date', style: AppTextStyles.caption),
            ElevatedButton(
              onPressed: () {}, // date picker logic
              child: Text('${_startDate.toLocal()}'.split(' ')[0]),
            ),
          ],
        ),
        Column(
          children: [
            Text('End Date', style: AppTextStyles.caption),
            ElevatedButton(
              onPressed: () {}, // date picker logic
              child: Text('${_endDate.toLocal()}'.split(' ')[0]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressListener(Stream<dynamic>? stream) {
    if (stream == null) return const Center(child: CircularProgressIndicator());
    return StreamBuilder<dynamic>(
      stream: stream.where((event) => event['type'] == 'backtest_progress' || event['type'] == 'backtest_done'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator(color: AppColors.primaryNeon);
        }

        final event = snapshot.data;
        if (event['type'] == 'backtest_done') {
          return Column(
            children: [
              Text('Backtest Complete!', style: AppTextStyles.heading2.copyWith(color: AppColors.successGreen)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {}, 
                icon: const Icon(Icons.download),
                label: const Text('Download Excel Report'),
              )
            ],
          );
        }

        final data = event['data'] as Map<String, dynamic>;
        final phase = data['phase'] ?? 'Starting...';
        final barsDone = data['bars_done'] ?? 0;
        final barsTotal = data['bars_total'] ?? 1;
        final pct = (barsDone / barsTotal).clamp(0.0, 1.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phase: $phase', style: AppTextStyles.bodyText),
            const SizedBox(height: 10),
            LinearPercentIndicator(
              lineHeight: 14.0,
              percent: pct,
              backgroundColor: AppColors.surfaceDark,
              progressColor: AppColors.primaryNeon,
              barRadius: const Radius.circular(10),
            ),
            const SizedBox(height: 10),
            Text('W: ${data['win']} | L: ${data['loss']} | PnL: \$${data['profit']}', style: AppTextStyles.bodyText),
          ],
        );
      },
    );
  }
}
