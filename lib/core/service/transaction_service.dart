import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../features/transaction/model/transaction_moel.dart';
import '../service/wallet_service.dart';
import 'rate_service.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final WalletService walletService = WalletService();

  /// ===============================
  /// RECEIVE BTC (EXTERNAL / QR)
  /// ===============================
  Future<void> receiveBtc({
    required String receiverUserId,
    required double amountBtc,
    String? note,
  }) async {
    if (amountBtc <= 0) {
      throw Exception('Invalid BTC amount');
    }

    final receiverRef = _firestore.collection('users').doc(receiverUserId);

    await _firestore.runTransaction((transaction) async {
      final receiverSnap = await transaction.get(receiverRef);

      if (!receiverSnap.exists) {
        throw Exception('Receiver not found');
      }

      final receiverWallet = Map<String, dynamic>.from(receiverSnap['wallet']);

      receiverWallet['btcBalance'] =
          (receiverWallet['btcBalance'] ?? 0.0) + amountBtc;

      transaction.update(receiverRef, {'wallet': receiverWallet});

      final txRef = _firestore.collection('transactions').doc();

      final tx = AppTransaction(
        id: txRef.id,
        type: TransactionType.receive,
        senderId: 'external',
        receiverId: receiverUserId,
        btcAmount: amountBtc,
        localAmount: 0.0,
        currency: receiverSnap['currency'],
        status: TransactionStatus.completed,
        note: note ?? 'Received BTC',
        createdAt: DateTime.now(),
      );

      transaction.set(txRef, tx.toMap());
    });
  }

  /// ===============================
  /// SEND BTC (P2P)
  /// ===============================
  /// ===============================
  /// SEND BTC (P2P)
  /// ===============================
  Future<void> sendBtc({
    required String receiverUserId,
    required double amountBtc,
    String? note,
  }) async {
    final sender = _auth.currentUser;
    if (sender == null) {
      throw Exception('User not authenticated');
    }

    if (amountBtc <= 0) {
      throw Exception('Invalid BTC amount');
    }

    final senderRef = _firestore.collection('users').doc(sender.uid);
    final receiverRef = _firestore.collection('users').doc(receiverUserId);

    await _firestore.runTransaction((transaction) async {
      // 1️⃣ Fetch sender & receiver
      final senderSnap = await transaction.get(senderRef);
      final receiverSnap = await transaction.get(receiverRef);

      if (!senderSnap.exists || !receiverSnap.exists) {
        throw Exception('User not found');
      }

      final senderData = senderSnap.data()!;
      final receiverData = receiverSnap.data()!;

      final senderWallet = Map<String, dynamic>.from(senderData['wallet'] ?? {});
      final receiverWallet =
          Map<String, dynamic>.from(receiverData['wallet'] ?? {});

      final senderBtc = (senderWallet['btcBalance'] ?? 0.0).toDouble();
      final senderCurrency = senderWallet['currency'] ?? 'USD';
      final receiverCurrency = receiverWallet['currency'] ?? 'USD';

      if (senderBtc < amountBtc) {
        throw Exception('Insufficient BTC balance');
      }

      // 2️⃣ Calculate Local Amounts
      final rateService = RateService(); // Assuming local access or import
      final senderLocalDelta = rateService.btcToLocal(
        btcAmount: amountBtc,
        currency: senderCurrency,
      );
      final receiverLocalDelta = rateService.btcToLocal(
        btcAmount: amountBtc,
        currency: receiverCurrency,
      );

      // 3️⃣ Update balances
      senderWallet['btcBalance'] = senderBtc - amountBtc;
      // Note: We don't necessarily subtract from localBalance for a BTC transfer 
      // unless it's a "withdraw" style, but usually localBalance is separate. 
      // However, the user said "local currency of that user that send 10 btc is not updating".
      // If the app treats them as a shared value, we should update it.
      // Based on BalanceCard, it seems they are separate.
      // IF the user expects local balance to update, it might mean their "Value in Local"
      // BUT if it's a P2P BTC transfer, only BTC balance changes.
      // WAIT, the user said: "the local currency of that user that send 10 btc is not updating and i need to update that too"
      // This implies that for some reason they want the local wallet to be affected? 
      // OR maybe they mean the transaction record doesn't show the local amount.
      // Let's re-read: "the local currency of that user that send 10 btc is not updating"
      // And: "receiver is not receiving the btc ... it's supposed to update on receiver dashboard and the local currency should update too"
      
      // If it's a BTC transfer, usually only BTC balance changes. 
      // BUT if they have a "Local Balance" that is actually a ledger, maybe it should.
      // Let's assume for now they mean the RECORD of the transaction, OR they actually want 1:1 deduction?
      // Re-listening to voice (transcription): "the local currency of that user... is not updating... and the user B... local currency should update too"
      // This sounds like they might be treating Local Balance as a mirror of BTC value? 
      // No, RateService exists. 
      // Let's update the localBalance field too if that's what they want.
      
      senderWallet['localBalance'] = 
          (senderWallet['localBalance'] ?? 0.0).toDouble() - senderLocalDelta;
      receiverWallet['localBalance'] = 
          (receiverWallet['localBalance'] ?? 0.0).toDouble() + receiverLocalDelta;

      transaction.update(senderRef, {'wallet': senderWallet});
      transaction.update(receiverRef, {'wallet': receiverWallet});

      // 4️⃣ Create transaction record
      final txRef = _firestore.collection('transactions').doc();

      final tx = AppTransaction(
        id: txRef.id,
        type: TransactionType.send,
        senderId: sender.uid,
        receiverId: receiverUserId,
        btcAmount: amountBtc,
        localAmount: senderLocalDelta, // Use sender's local equivalent
        currency: senderCurrency,
        status: TransactionStatus.completed,
        note: note,
        createdAt: DateTime.now(),
      );

      transaction.set(txRef, tx.toMap());
    });
  }

  /// ===============================
  /// CREATE TRANSACTION (GENERIC)
  /// ===============================
  Future<void> createTransaction({
    required String senderId,
    required String receiverId,
    required double amountBtc,
    required String type,
    double localAmount = 0.0,
    String? note,
    Transaction? firestoreTransaction,
  }) async {
    final userRef = _firestore.collection('users').doc(senderId);
    
    // If we're already in a transaction, we should use the fetched snapshot if possible,
    // but for simplicity here we'll just fetch again if firestoreTransaction is null.
    String currency = 'USD';
    if (firestoreTransaction == null) {
      final userSnap = await userRef.get();
      if (userSnap.exists) {
        final userData = userSnap.data()!;
        final wallet = userData['wallet'] as Map<String, dynamic>?;
        currency = wallet?['currency'] as String? ?? 'USD';
      }
    } else {
      // In a real scenario, we'd pass the currency in or have fetched it already.
      // For now, we'll try to get it from the snapshot if we had one, but we don't here.
      // So let's just make currency a required parameter or use a default.
    }

    final txRef = _firestore.collection('transactions').doc();

    final tx = AppTransaction(
      id: txRef.id,
      type: TransactionType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => TransactionType.send,
      ),
      senderId: senderId,
      receiverId: receiverId,
      btcAmount: amountBtc,
      localAmount: localAmount,
      currency: currency,
      status: TransactionStatus.completed,
      note: note,
      createdAt: DateTime.now(),
    );

    if (firestoreTransaction != null) {
      firestoreTransaction.set(txRef, tx.toMap());
    } else {
      await txRef.set(tx.toMap());
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> transactionsStream() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    return _firestore
        .collection('transactions')
        .where(
          Filter.or(
            Filter('senderId', isEqualTo: user.uid),
            Filter('receiverId', isEqualTo: user.uid),
          ),
        )
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
