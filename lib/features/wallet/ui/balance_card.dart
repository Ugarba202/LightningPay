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
        final btc = wallet['btcBalance'] ?? 0.0;
        final local = wallet['localBalance'] ?? 0.0;
        final currency = wallet['currency'] ?? '—';

        final btcDisplay = btc % 1 == 0 ? btc.toInt().toString() : btc.toString();
        final localDisplay = local.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );

        return GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(
                  color: AppColors.textMed,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              /// BTC Balance
              Text(
                '$btcDisplay BTC',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHigh,
                ),
              ),

              const SizedBox(height: 6),

              /// Local Currency Balance
              Text(
                '$localDisplay $currency',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textMed,
                ),
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
