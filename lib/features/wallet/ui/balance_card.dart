import 'package:flutter/material.dart';
import '../../../core/data/wallet_store.dart';
import '../../../core/themes/app_colors.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ValueListenableBuilder<double>(
          valueListenable: WalletStore().balanceBTC,
          builder: (context, balance, _) {
            final balanceUSD = balance * 65000.0; // Mock rate
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '${balance.toStringAsFixed(8).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")} BTC',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '≈ \$${balanceUSD.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
