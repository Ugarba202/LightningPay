import '../../../core/service/wallet_service.dart';
import '../../../core/service/transaction_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WithdrawLogic {
  final WalletService _walletService = WalletService();
  final TransactionService _txService = TransactionService();

  bool validateAmount(String amount) {
    final value = double.tryParse(amount);
    return value != null && value > 0;
  }

  Future<String?> checkBalance(String amount) async {
    final value = double.tryParse(amount);
    if (value == null) return "Invalid amount";

    try {
      final wallet = await _walletService.getMyWallet();
      final localBalance = (wallet['localBalance'] ?? 0.0).toDouble();
      if (localBalance < value) {
        return "Insufficient local balance";
      }
      return null;
    } catch (e) {
      return "Could not verify balance";
    }
  }

  Future<void> processWithdraw({
    required String amount,
    required String type,
    required String destination,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final value = double.tryParse(amount);
    if (value == null || value <= 0) throw Exception('Invalid amount');

    // 1️⃣ Update Firestore balance (updateBalancesSafely handles sufficiency check)
    await _walletService.updateBalancesSafely(
      btcDelta: 0.0,
      localDelta: -value,
    );

    // 2️⃣ Record transaction
    await _txService.createTransaction(
      senderId: user.uid,
      receiverId: 'external',
      amountBtc: 0.0,
      type: 'withdraw',
      note: 'Withdraw to $destination ($type)',
    );
  }
}
