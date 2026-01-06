import 'package:firebase_auth/firebase_auth.dart';

import 'wallet_balance_service.dart';
import 'transaction_service.dart';

class ReceiveService {
  final _walletService = WalletBalanceService();
  final _txService = TransactionService();
  final _auth = FirebaseAuth.instance;

  /// 🟢 Credit BTC to current user (receive, faucet, lightning)
  Future<void> receiveBtc({required double amountBtc, String? note}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    if (amountBtc <= 0) {
      throw Exception('Invalid BTC amount');
    }

    // 1️⃣ Credit wallet
    await _walletService.creditBtc(userId: user.uid, amountBtc: amountBtc);

    // 2️⃣ Record transaction
    await _txService.receiveBtc(
      receiverUserId: user.uid,
      amountBtc: amountBtc,
      note: note,
    );
  }
}
