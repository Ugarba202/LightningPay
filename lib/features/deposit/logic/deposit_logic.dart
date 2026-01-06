import '../../../core/service/wallet_service.dart';
import '../../../core/service/transaction_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DepositLogic {
  final WalletService _walletService = WalletService();
  final TransactionService _txService = TransactionService();

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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      // 1️⃣ Update Firestore balance
      await _walletService.updateBalancesSafely(
        btcDelta: 0.0,
        localDelta: value,
      );

      // 2️⃣ Record transaction
      await _txService.createTransaction(
        senderId: 'external',
        receiverId: user.uid,
        amountBtc: 0.0,
        type: 'deposit',
        note: purpose.isNotEmpty ? purpose : 'Deposited funds',
      );
    }
  }
}
