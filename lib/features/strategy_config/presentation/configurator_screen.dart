import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

// Placeholder for full implementation. In a real scenario, this would use dio PUT requests.
class ConfiguratorScreen extends ConsumerStatefulWidget {
  const ConfiguratorScreen({super.key});

  @override
  ConsumerState<ConfiguratorScreen> createState() => _ConfiguratorScreenState();
}

class _ConfiguratorScreenState extends ConsumerState<ConfiguratorScreen> {
  double lotSize = 0.05;
  double trailPoints = 200;
  String maType = 'DEMA';
  bool useMtf = true;

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
        title: Text('Strategy & Risk', style: AppTextStyles.heading2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Strategy Configuration'),
          _buildDropdown('MA Type', ['DEMA', 'TEMA', 'EMA', 'SMA'], maType, (v) => setState(() => maType = v!)),
          _buildSwitch('Multi-Timeframe (MTF)', useMtf, (v) => setState(() => useMtf = v)),
          const SizedBox(height: 20),
          _buildSectionHeader('Risk Management'),
          _buildSlider('Lot Size', lotSize, 0.01, 1.0, (v) => setState(() => lotSize = v)),
          _buildSlider('Trailing Points', trailPoints, 10, 500, (v) => setState(() => trailPoints = v)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // Call API to save via provider
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Config Saved!')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNeon,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Save Configuration', style: AppTextStyles.bodyText.copyWith(color: AppColors.backgroundDark, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(title, style: AppTextStyles.heading2.copyWith(color: AppColors.primaryNeon)),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label, style: AppTextStyles.bodyText),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryNeon,
    );
  }

  Widget _buildDropdown(String label, List<String> options, String value, ValueChanged<String?> onChanged) {
    return ListTile(
      title: Text(label, style: AppTextStyles.bodyText),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: AppColors.surfaceDark,
        style: AppTextStyles.bodyText,
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}', style: AppTextStyles.bodyText),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.primaryNeon,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
