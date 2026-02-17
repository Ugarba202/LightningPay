import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:breez_sdk/bridge_generated.dart';
import 'breeze_service.dart';

class WalletStreamService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// 🔥 Live wallet stream (BTC + local)
  /// Combines Firestore user data with real-time Breez node state.
  Stream<Map<String, dynamic>> walletStream() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    final controller = StreamController<Map<String, dynamic>>();
    
    Map<String, dynamic> lastFirestoreData = {};
    NodeState? lastNodeState;

    void emit() {
      if (lastFirestoreData.isEmpty) return;
      
      final wallet = Map<String, dynamic>.from(lastFirestoreData['wallet'] ?? {});
      
      // Merge Breez balances
      double lightningBalance = 0;
      double onchainBalance = 0;
      
      if (lastNodeState != null) {
        lightningBalance = lastNodeState!.channelsBalanceMsat / 1000;
        onchainBalance = lastNodeState!.onchainBalanceMsat / 1000;
      }
      
      wallet['lightningBalance'] = lightningBalance;
      wallet['onchainBalance'] = onchainBalance;
      wallet['totalRealBalance'] = lightningBalance + onchainBalance;
      
      controller.add(wallet);
    }

    // 1. Listen to Firestore
    final firestoreSub = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        lastFirestoreData = doc.data() ?? {};
        emit();
      }
    });

    // 2. Listen to Breez Node State (Real-time balance updates)
    final breezSub = BreezeService.instance.nodeStateStream.listen((state) {
      lastNodeState = state;
      emit();
    });

    // Handle initial fetch for state if not yet emitted by stream
    BreezeService.instance.nodeInfo().then((state) {
      if (lastNodeState == null) {
        lastNodeState = state;
        emit();
      }
    });

    controller.onCancel = () {
      firestoreSub.cancel();
      breezSub.cancel();
      controller.close();
    };

    return controller.stream;
  }
}
