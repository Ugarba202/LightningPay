import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/service/wallet_service.dart';
import '../../../core/service/transaction_service.dart';

class WithdrawLogic {
  final WalletService _walletService = WalletService();
  final TransactionService _txService = TransactionService();

  bool validateAmount(String amount) {
    final value = double.tryParse(amount);
    return value != null && value > 0;
  }

  Future<String?> checkBalance(String amount) async {
    final value = double.tryParse(amount);
    if (value == null) return 'Invalid amount';

    try {
      final wallet = await _walletService.walletStream().first;
      final localBalance = (wallet['localBalance'] ?? 0).toDouble();

      if (localBalance < value) {
        return 'Insufficient local balance';
      }
      return null;
    } catch (_) {
      return 'Unable to verify balance';
    }
  }

  Future<void> processWithdraw({
    required String amount,
    required String destination, required String type,
  }) async {
    final value = double.tryParse(amount);
    if (value == null || value <= 0) {
      throw Exception('Invalid amount');
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    // 1️⃣ Subtract local balance safely
    await _walletService.subtractLocal(value);

    // 2️⃣ Record transaction
    await _txService.recordTransaction(
      type: 'withdraw',
      amountLocal: value,
      note: 'Withdrawal to $destination', senderId: '', receiverId: '', amountBtc: 0.0,
    );
  }
}
