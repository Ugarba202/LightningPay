import 'dart:ui';
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
      backgroundColor: AppColors.bgDark,
      extendBody: true, // Allow body to flow behind the glass bar
      body: _screens[_currentIndex],
      bottomNavigationBar: _CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding + 16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: AppColors.surfaceDark.withOpacity(0.8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavBarItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Wallet',
                    isActive: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavBarItem(
                    icon: Icons.history_rounded,
                    label: 'History',
                    isActive: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _NavBarItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    isActive: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textMed,
              size: isActive ? 24 : 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
