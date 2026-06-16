import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/api/ws_client.dart';

class LiveRadarScreen extends ConsumerStatefulWidget {
  const LiveRadarScreen({super.key});

  @override
  ConsumerState<LiveRadarScreen> createState() => _LiveRadarScreenState();
}

class _LiveRadarScreenState extends ConsumerState<LiveRadarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Connect to WebSocket when opening this screen if not already connected
    ref.read(wsClientProvider).connect();
  }

  @override
  Widget build(BuildContext context) {
    final wsStream = ref.watch(wsClientProvider).stream;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        title: Text('Live Radar & Positions', style: AppTextStyles.heading2),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryNeon,
          labelColor: AppColors.primaryNeon,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Positions'),
            Tab(text: 'Scanner Terminal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPositionsTab(wsStream),
          _buildScannerTab(wsStream),
        ],
      ),
    );
  }

  Widget _buildPositionsTab(Stream<dynamic>? stream) {
    if (stream == null) return const Center(child: CircularProgressIndicator());
    return StreamBuilder<dynamic>(
      stream: stream.where((event) => event['type'] == 'positions_pnl'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: Text('Waiting for data...', style: TextStyle(color: Colors.white)));
        final data = snapshot.data['data'] as Map<String, dynamic>? ?? {};
        if (data.isEmpty) return const Center(child: Text('No active positions.', style: TextStyle(color: Colors.white)));

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            String key = data.keys.elementAt(index);
            double pnl = data[key];
            return ListTile(
              leading: Icon(pnl >= 0 ? Icons.trending_up : Icons.trending_down, color: pnl >= 0 ? AppColors.successGreen : AppColors.dangerRed),
              title: Text('Position #$key', style: AppTextStyles.bodyText),
              trailing: Text('\$${pnl.toStringAsFixed(2)}', style: AppTextStyles.bodyText.copyWith(color: pnl >= 0 ? AppColors.successGreen : AppColors.dangerRed)),
            );
          },
        );
      },
    );
  }

  Widget _buildScannerTab(Stream<dynamic>? stream) {
    if (stream == null) return const Center(child: CircularProgressIndicator());
    return StreamBuilder<dynamic>(
      stream: stream.where((event) => event['type'] == 'market_pulse'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: Text('Waiting for pulse...', style: TextStyle(color: Colors.white)));
        final data = snapshot.data['data'] as Map<String, dynamic>? ?? {};
        
        return Container(
          color: Colors.black, // Terminal feel
          padding: const EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              String tf = data.keys.elementAt(index);
              String pulse = data[tf];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('[$tf] $pulse', style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace')),
              );
            },
          ),
        );
      },
    );
  }
}
