import '../../../core/data/wallet_store.dart';

class DepositLogic {
  final WalletStore _walletStore = WalletStore();

  bool validateAmount(String amount) {
    final value = double.tryParse(amount);
    return value != null && value > 0;
  }

  Future<void> processDeposit({
    required String amount,
    required String currency,
    required String purpose,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final value = double.tryParse(amount);
    if (value != null && value > 0) {
      // User clarified: This only funds the local currency balance.
      // BTC remains unchanged and no conversion occurs.
      _walletStore.depositLocal(value);
    }
  }
}
