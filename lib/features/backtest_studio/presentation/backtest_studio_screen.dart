import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

class BacktestStudioScreen extends ConsumerStatefulWidget {
  const BacktestStudioScreen({super.key});

  @override
  ConsumerState<BacktestStudioScreen> createState() => _BacktestStudioScreenState();
}

class _BacktestStudioScreenState extends ConsumerState<BacktestStudioScreen> {
  int _days = 7;
  bool _isRunning = false;
  double _progress = 0.0;
  String _phase = 'Idle';
  Map<String, dynamic>? _result;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _startBacktest() async {
    final api = ref.read(apiClientProvider);
    try {
      await api.startBacktest(_days);
      setState(() {
        _isRunning = true;
        _progress = 0.0;
        _phase = 'Initializing...';
        _result = null;
      });
      _timer = Timer.periodic(const Duration(seconds: 2), (t) => _checkStatus());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _checkStatus() async {
    if (!mounted) return;
    final api = ref.read(apiClientProvider);
    try {
      final status = await api.getBacktestStatus();
      if (status['status'] == 'idle') {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          _progress = 1.0;
          _phase = 'Completed!';
          if (status['result'] != null) {
             _result = status['result'];
          }
        });
      } else if (status['status'] == 'running') {
        setState(() {
          _isRunning = true;
          _progress = (status['progress'] ?? 0) / 100.0;
          _phase = status['phase'] ?? 'Simulating...';
        });
      }
    } catch (_) {}
  }

  Future<void> _downloadExcel() async {
    final url = Uri.parse('http://192.168.1.100:10000/api/backtest/download');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch browser to download file.')));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceGlass, width: 1),
              ),
              child: Column(
                children: [
                  Icon(Icons.history_toggle_off, size: 60, color: AppColors.primaryNeon),
                  const SizedBox(height: 10),
                  Text('Triple Engine Simulator', style: AppTextStyles.heading1),
                  const SizedBox(height: 10),
                  Text(
                    'Simulate your exact TEMA, SMA, and Hybrid strategies against historical data before risking real capital.',
                    style: AppTextStyles.bodyText,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fade().scale(),
            const SizedBox(height: 40),
            
            Text('Historical Range (Days)', style: AppTextStyles.heading2),
            Slider(
              value: _days.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              activeColor: AppColors.primaryNeon,
              label: '$_days Days',
              onChanged: _isRunning ? null : (val) => setState(() => _days = val.toInt()),
            ),
            Center(
              child: Text(
                '$_days Days',
                style: AppTextStyles.heading1.copyWith(color: AppColors.primaryNeon),
              ),
            ),
            
            const SizedBox(height: 40),
            
            if (_isRunning) ...[
              Text(_phase, style: AppTextStyles.bodyText, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppColors.surfaceGlass,
                color: AppColors.primaryNeon,
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 10),
              Text('${(_progress * 100).toStringAsFixed(1)}%', style: AppTextStyles.caption, textAlign: TextAlign.center),
            ] else if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.primaryNeon, width: 1),
                ),
                child: Column(
                  children: [
                    Text('Backtest Complete ✅', style: AppTextStyles.heading2.copyWith(color: AppColors.successGreen)),
                    const SizedBox(height: 10),
                    Text(_result!['caption'] ?? '', style: AppTextStyles.bodyText, textAlign: TextAlign.left),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _downloadExcel,
                      icon: const Icon(Icons.download, color: Colors.black),
                      label: Text('Download Excel Report', style: AppTextStyles.bodyText.copyWith(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ).animate().fade().slideY(),
            ],
            
            const SizedBox(height: 40),
            
            SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isRunning ? null : _startBacktest,
                icon: _isRunning 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.rocket_launch, color: Colors.black),
                label: Text(
                  _isRunning ? 'SIMULATING...' : 'START BACKTEST', 
                  style: AppTextStyles.heading2.copyWith(color: _isRunning ? Colors.white : Colors.black)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNeon,
                  disabledBackgroundColor: AppColors.surfaceGlass,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ).animate().slideY(begin: 0.5),
          ],
        ),
      ),
    );
  }
}
