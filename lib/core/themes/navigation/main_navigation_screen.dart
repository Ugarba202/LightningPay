import 'package:flutter/material.dart';
import 'package:lighting_pay/features/profile/ui/profile_screen.dart';

import '../../../features/auth/ui/transaction_pin_flow.dart';
import '../../../features/transaction/ui/transaction_history_screen.dart';
import '../../../features/wallet/ui/wallet_dashboard_screen.dart'
    show WalletDashboardScreen;


import '../../../core/storage/auth_storage.dart';

import '../app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    WalletDashboardScreen(),
    TransactionHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _maybeShowTransactionSetupPrompt();
  }

  Future<void> _maybeShowTransactionSetupPrompt() async {
    final need = await AuthStorage.needsTransactionSetup();
    if (need) {
      // Wait a short period to let dashboard settle
      Future.delayed(const Duration(seconds: 3), () async {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => const TransactionPinFlow(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
