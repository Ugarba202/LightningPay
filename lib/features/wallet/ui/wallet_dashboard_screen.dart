import 'package:flutter/material.dart';
import 'package:lighting_pay/features/send/ui/send_amount_screen.dart';

import '../../../core/themes/app_colors.dart';
import '../../receive/ui/receive_screen.dart';
import '../../transaction/ui/transaction_history_screen.dart';
import 'balance_card.dart';

class WalletDashboardScreen extends StatelessWidget {
  const WalletDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BalanceCard(),
            const SizedBox(height: 32),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionButton(
                  icon: Icons.arrow_upward,
                  label: 'Send',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SendAmountScreen()),
                  ),
                ),
                _ActionButton(
                  icon: Icons.arrow_downward,
                  label: 'Receive',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReceiveScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TransactionHistoryScreen(),
                  ),
                );
              },
              child: Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            const SizedBox(height: 16),

            // Placeholder transactions
            _TransactionTile(
              title: 'Lightning Payment',
              subtitle: 'Sent • Today',
              amount: '-0.002 BTC',
            ),
            _TransactionTile(
              title: 'Bitcoin Receive',
              subtitle: 'Received • Yesterday',
              amount: '+0.010 BTC',
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;

  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        amount,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
