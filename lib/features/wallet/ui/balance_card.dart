import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/service/wallet_stream_service.dart';
import '../../../core/themes/widgets/glass_card.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final walletStream = WalletStreamService();

    return StreamBuilder<Map<String, dynamic>>(
      stream: walletStream.walletStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingCard();
        }

        if (!snapshot.hasData) {
          return _errorCard('Wallet not found');
        }

        final wallet = snapshot.data!;
        final lightning = (wallet['lightningBalance'] ?? 0.0).toDouble();
        final onchain = (wallet['onchainBalance'] ?? 0.0).toDouble();
        final totalReal = (wallet['totalRealBalance'] ?? 0.0).toDouble();
        final local = (wallet['localBalance'] ?? 0.0).toDouble();
        final currency = wallet['currency'] ?? '—';

        final localDisplay = local.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );

        return GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Real Balance',
                    style: TextStyle(
                      color: AppColors.textMed,
                      fontSize: 14,
                    ),
                  ),
                  const Icon(Icons.bolt, color: Colors.amber, size: 16),
                ],
              ),
              const SizedBox(height: 12),

              /// Total Real Balance
              Text(
                '${totalReal.toStringAsFixed(totalReal < 1 && totalReal > 0 ? 6 : 0)} sats',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHigh,
                ),
              ),

              const SizedBox(height: 12),
              
              Row(
                children: [
                   _BalanceSmall(label: 'LN', value: '${lightning.toInt()}'),
                   const SizedBox(width: 16),
                   _BalanceSmall(label: 'On-chain', value: '${onchain.toInt()}'),
                ],
              ),

              const Divider(height: 32, color: Colors.white10),

              /// Local Currency Balance (Simulated/Internal)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Local Account',
                    style: TextStyle(fontSize: 14, color: AppColors.textMed),
                  ),
                  Text(
                    '$localDisplay $currency',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
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
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _errorCard(String message) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}

class _BalanceSmall extends StatelessWidget {
  final String label;
  final String value;

  const _BalanceSmall({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMed)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textHigh)),
      ],
    );
  }
}
