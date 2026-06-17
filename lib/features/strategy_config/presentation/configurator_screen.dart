import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../dashboard/providers/bot_state_provider.dart';

class ConfiguratorScreen extends ConsumerWidget {
  const ConfiguratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final botState = ref.watch(botStateProvider);
    if (botState.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon));
    }

    final basisType = botState['basis_type'] ?? 'DEMA';
    final basisLen = botState['basis_len'] ?? 30;
    final useMtf = botState['use_mtf'] ?? true;
    final useMa = botState['use_ma'] ?? true;
    final lotSize = botState['lot_size'] ?? 0.05;
    final dailyLossEnabled = botState['daily_loss_enabled'] ?? false;
    final dailyLossUsd = botState['daily_loss_usd'] ?? 100.0;
    final dailyTargetEnabled = botState['daily_target_enabled'] ?? false;
    final dailyTargetUsd = botState['daily_target_usd'] ?? 100.0;
    
    final activeTfs = botState['active_tfs'] as Map<String, dynamic>? ?? {};

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
        title: Text('Strategy & Risk', style: AppTextStyles.heading2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(Icons.auto_graph, 'Moving Average Core'),
          _buildDropdownTile(
            'Moving Average Base',
            botState['basis_type'] ?? 'DEMA',
            ['SMA', 'EMA', 'WMA', 'DEMA', 'TEMA', 'SMMA', 'HULLMA', 'LSMA'],
            (val) => ref.read(botStateProvider.notifier).updateConfig({'basis_type': val}),
          ),
          _buildNumberInputTile(
            'MA Length',
            basisLen,
            false,
            (val) => ref.read(botStateProvider.notifier).updateConfig({'basis_len': val.toInt()}),
          ),
          _buildSwitchTile(
            'Enable MA Trend Filter',
            useMa,
            (val) => ref.read(botStateProvider.notifier).updateConfig({'use_ma': val}),
          ),

          const SizedBox(height: 30),
          _buildSectionHeader(Icons.layers, 'Multi-Timeframe Engine'),
          _buildSwitchTile(
            'Require MTF Alignment',
            useMtf,
            (val) => ref.read(botStateProvider.notifier).updateConfig({'use_mtf': val}),
          ),
          const SizedBox(height: 10),
          Text('Active Timeframes:', style: AppTextStyles.bodyText),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: activeTfs.entries.map((e) => FilterChip(
              label: Text(e.key.toUpperCase()),
              selected: e.value == true,
              selectedColor: AppColors.primaryNeon.withAlpha(50),
              checkmarkColor: AppColors.primaryNeon,
              onSelected: (val) {
                final newTfs = Map<String, dynamic>.from(activeTfs);
                newTfs[e.key] = val;
                ref.read(botStateProvider.notifier).updateConfig({'active_tfs': newTfs});
              },
            )).toList(),
          ),

          const SizedBox(height: 30),
          _buildSectionHeader(Icons.security, 'Risk Management'),
          _buildNumberInputTile(
            'Fixed Lot Size',
            lotSize,
            true,
            (val) => ref.read(botStateProvider.notifier).updateConfig({'lot_size': val.toDouble()}),
          ),
          _buildSwitchTile(
            'Enable Daily Loss Limit',
            dailyLossEnabled,
            (val) => ref.read(botStateProvider.notifier).updateConfig({'daily_loss_enabled': val}),
          ),
          if (dailyLossEnabled)
            _buildNumberInputTile(
              'Max Daily Loss (\$)',
              dailyLossUsd,
              true,
              (val) => ref.read(botStateProvider.notifier).updateConfig({'daily_loss_usd': val.toDouble()}),
            ),
          
          _buildSwitchTile(
            'Enable Daily Profit Target',
            dailyTargetEnabled,
            (val) => ref.read(botStateProvider.notifier).updateConfig({'daily_target_enabled': val}),
          ),
          if (dailyTargetEnabled)
            _buildNumberInputTile(
              'Daily Profit Target (\$)',
              dailyTargetUsd,
              true,
              (val) => ref.read(botStateProvider.notifier).updateConfig({'daily_target_usd': val.toDouble()}),
            ),
          
          const SizedBox(height: 30),
          _buildSectionHeader(Icons.shield, 'Advanced Protections & Exits'),
          _buildSwitchTile(
            'Enable Break-Even (BE)',
            botState['use_be'] ?? false,
            (val) => ref.read(botStateProvider.notifier).updateConfig({'use_be': val}),
          ),
          _buildSwitchTile(
            'Enable Trailing Stop',
            botState['use_trailing'] ?? false,
            (val) => ref.read(botStateProvider.notifier).updateConfig({'use_trailing': val}),
          ),
          if (botState['use_trailing'] == true) ...[
            _buildNumberInputTile(
              'Trailing Points',
              botState['trail_points'] ?? 200,
              false,
              (val) => ref.read(botStateProvider.notifier).updateConfig({'trail_points': val.toInt()}),
            ),
            _buildNumberInputTile(
              'Trailing Offset',
              botState['trail_offset'] ?? 400,
              false,
              (val) => ref.read(botStateProvider.notifier).updateConfig({'trail_offset': val.toInt()}),
            ),
          ],
          _buildSwitchTile(
            'Enable Danger Zone Filter',
            botState['use_danger_filter'] ?? true,
            (val) => ref.read(botStateProvider.notifier).updateConfig({'use_danger_filter': val}),
          ),
          _buildSwitchTile(
            'Use Max Spread Protection',
            botState['use_max_spread'] ?? true,
            (val) => ref.read(botStateProvider.notifier).updateConfig({'use_max_spread': val}),
          ),
          if (botState['use_max_spread'] == true)
            _buildNumberInputTile(
              'Max Spread Limit (Pips)',
              botState['max_spread_pips'] ?? 3.0,
              true,
              (val) => ref.read(botStateProvider.notifier).updateConfig({'max_spread_pips': val.toDouble()}),
            ),
            
          const SizedBox(height: 40),
        ],
      ).animate().fade().slideY(begin: 0.1),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryNeon, size: 24),
          const SizedBox(width: 10),
          Text(title, style: AppTextStyles.heading2),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.bodyText),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryNeon,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildNumberInputTile(String title, num value, bool isDouble, ValueChanged<num> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: AppTextStyles.bodyText)),
          SizedBox(
            width: 100,
            child: TextField(
              controller: TextEditingController(text: isDouble ? (value as double).toStringAsFixed(2) : value.toString()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.heading2.copyWith(color: AppColors.primaryNeon, fontSize: 16),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.backgroundDark,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.surfaceGlass),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.surfaceGlass),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryNeon),
                ),
              ),
              onSubmitted: (val) {
                final num? parsed = isDouble ? double.tryParse(val) : int.tryParse(val);
                if (parsed != null) {
                  onChanged(parsed);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(String title, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.bodyText),
          DropdownButton<String>(
            value: value,
            dropdownColor: AppColors.surfaceDark,
            style: AppTextStyles.bodyText.copyWith(color: AppColors.primaryNeon),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
