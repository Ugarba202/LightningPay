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
      // In a real app, we'd convert currency to BTC here.
      // For mock, we'll just treat the input amount as BTC if it's small, 
      // or assume a conversion happening behind the scenes for large fiat numbers.
      // To keep it simple and visible: 
      // If currency is BTC, just add. 
      // If fiat, we'll convert mockly: 1 USD = 0.000015 BTC approx.
      
      double finalBtcAmount = value;
      if (currency != 'BTC') {
         // Mock conversion for display
         // 1 USD ~ 0.000015 BTC
         // 1 NGN ~ 0.00000001 BTC
         if (currency == 'USD') finalBtcAmount = value * 0.000015;
         else if (currency == 'NGN') finalBtcAmount = value * 0.00000001;
         else finalBtcAmount = value * 0.000015; // default
      }

      _walletStore.deposit(finalBtcAmount);
    }
  }
}
