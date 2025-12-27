import '../../../core/data/wallet_store.dart';

class WithdrawLogic {
  final WalletStore _walletStore = WalletStore();

  bool validateAmount(String amount) {
    final value = double.tryParse(amount);
    return value != null && value > 0;
  }

  String? checkBalance(String amount) {
    final value = double.tryParse(amount);
    if (value == null) return "Invalid amount";
    if (!_walletStore.hasSufficientFunds(value)) {
      return "Insufficient balance";
    }
    return null;
  }

  Future<void> processWithdraw({
    required String amount,
    required String type, // 'Bank' or 'P2P'
    required String destination, // Account Number or Username
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final value = double.tryParse(amount);
    if (value != null) {
      // Mock deduction
      _walletStore.withdraw(value);
    }
  }
}
