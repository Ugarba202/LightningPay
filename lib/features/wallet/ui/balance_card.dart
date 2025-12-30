import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/service/user_respiratory.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/service/rate_service.dart';

import '../../../core/models/user_model.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepo = UserRepository();

    return StreamBuilder<AppUser>(
      stream: userRepo.getCurrentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _loadingCard();
        }

        final user = snapshot.data!;
        final localAmount = RateService.btcToLocal(
          btc: user.btcBalance,
          currency: user.currency,
        );

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.9),
                AppColors.primary.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wallet Balance',
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 12),

              // BTC Balance
              Text(
                '${user.btcBalance.toStringAsFixed(6)} BTC',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // Local Currency (NGN, PKR, etc)
              Text(
                '${localAmount.toStringAsFixed(2)} ${user.currency}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  _CopyChip(
                    label: '@${user.username}',
                    icon: Icons.alternate_email,
                  ),
                  const SizedBox(width: 12),
                  _CopyChip(
                    label: user.accountNumber,
                    icon: Icons.account_balance,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _loadingCard() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _CopyChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _CopyChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: label));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label copied')),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
