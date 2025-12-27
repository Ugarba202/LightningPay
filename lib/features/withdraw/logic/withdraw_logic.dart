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
    if (_walletStore.balanceLocal.value < value) {
      return "Insufficient local balance";
    }
    return null;
  }

  bool needsConversion() {
    // If local balance is 0 but BTC is not, suggest conversion
    return _walletStore.balanceLocal.value <= 0 && _walletStore.balanceBTC.value > 0;
  }

  Future<void> processWithdraw({
    required String amount,
    required String type,
    required String destination,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final value = double.tryParse(amount);
    if (value != null && _walletStore.balanceLocal.value >= value) {
      _walletStore.balanceLocal.value -= value;
    }
  }
}
