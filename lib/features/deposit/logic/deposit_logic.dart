import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/service/wallet_service.dart';
import '../../../core/service/transaction_service.dart';

class DepositLogic {
  final WalletService _walletService = WalletService();
  final TransactionService _txService = TransactionService();

  bool validateAmount(String amount) {
    final value = double.tryParse(amount);
    return value != null && value > 0;
  }

  Future<void> processDeposit({
    required String amount,
    required String purpose, required String currency,
  }) async {
    final value = double.tryParse(amount);
    if (value == null || value <= 0) {
      throw Exception('Invalid amount');
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    // 1️⃣ Update wallet balance safely
    await _walletService.addLocal(value);

    // 2️⃣ Record transaction
    await _txService.recordTransaction(
      type: 'deposit',
      amountLocal: value,
      note: purpose.isNotEmpty ? purpose : 'Deposited funds',
      senderId: '',
      receiverId: '',
      amountBtc: 0.0,
    );
  }
}
