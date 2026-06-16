import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/security/local_auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../dashboard/presentation/main_dashboard_screen.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  bool _isAuthenticating = false;

  Future<void> _authenticate() async {
    setState(() { _isAuthenticating = true; });
    final authService = ref.read(localAuthProvider);
    final success = await authService.authenticate();
    setState(() { _isAuthenticating = false; });

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainDashboardScreen()),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Please try again.'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: AppColors.primaryNeon,
            ).animate().fade(duration: 500.ms).scale(delay: 200.ms),
            const SizedBox(height: 30),
            Text(
              'Secure Trading Terminal',
              style: AppTextStyles.heading2,
            ).animate().fade(delay: 400.ms),
            const SizedBox(height: 50),
            _isAuthenticating
                ? const CircularProgressIndicator(color: AppColors.primaryNeon)
                : ElevatedButton.icon(
                    onPressed: _authenticate,
                    icon: const Icon(Icons.fingerprint, color: AppColors.textPrimary),
                    label: Text('Unlock Dashboard', style: AppTextStyles.bodyText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceDark,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: AppColors.primaryNeon, width: 1),
                      ),
                    ),
                  ).animate().fade(delay: 600.ms).slideY(begin: 0.5),
          ],
        ),
      ),
    );
  }
}
