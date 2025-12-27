import 'package:flutter/material.dart';
import 'package:lighting_pay/features/send/ui/send_amount_screen.dart';

import '../../../core/themes/app_colors.dart';
import '../../receive/ui/receive_screen.dart';
import '../../deposit/ui/deposit_screen.dart';
import '../../withdraw/ui/withdraw_screen.dart';
import '../../transaction/ui/transaction_history_screen.dart';
import 'balance_card.dart';

class WalletDashboardScreen extends StatelessWidget {
  const WalletDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background subtle gradient
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.03),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Wallet',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                          letterSpacing: 0.5,
                        ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none_rounded),
                        onPressed: () {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const BalanceCard(),
                      const SizedBox(height: 40),
                      
                      // Action Buttons Grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ActionButton(
                            icon: Icons.send_rounded,
                            label: 'Send',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SendAmountScreen()),
                            ),
                          ),
                          _ActionButton(
                            icon: Icons.qr_code_2_rounded,
                            label: 'Receive',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ReceiveScreen()),
                            ),
                          ),
                          _ActionButton(
                            icon: Icons.add_circle_rounded,
                            label: 'Deposit',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DepositScreen()),
                            ),
                          ),
                          _ActionButton(
                            icon: Icons.account_balance_wallet_rounded,
                            label: 'Withdraw',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WithdrawScreen()),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 48),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Activity',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TransactionHistoryScreen(),
                                ),
                              );
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Recent Transactions
                      _TransactionTile(
                        title: 'Apple Signature',
                        subtitle: 'Sent • Today, 10:45 AM',
                        amount: '-0.00045 BTC',
                        icon: Icons.apple_rounded,
                      ),
                      const SizedBox(height: 12),
                      _TransactionTile(
                        title: 'Miners Reward',
                        subtitle: 'Received • Yesterday, 2:15 PM',
                        amount: '+0.0028 BTC',
                        icon: Icons.currency_bitcoin_rounded,
                        isPositive: true,
                      ),
                      const SizedBox(height: 12),
                      _TransactionTile(
                        title: 'Binance Exchange',
                        subtitle: 'Received • Dec 24, 8:12 PM',
                        amount: '+0.0150 BTC',
                        icon: Icons.swap_horizontal_circle_rounded,
                        isPositive: true,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border.withOpacity(0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMed,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final bool isPositive;

  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    this.isPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white70, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHigh,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMed,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isPositive ? AppColors.success : AppColors.textHigh,
            ),
          ),
        ],
      ),
    );
  }
}

