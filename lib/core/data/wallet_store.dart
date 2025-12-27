import 'package:flutter/foundation.dart';

class WalletStore {
  // Singleton pattern
  static final WalletStore _instance = WalletStore._internal();
  factory WalletStore() => _instance;
  WalletStore._internal();

  // Observable balances
  final ValueNotifier<double> balanceBTC = ValueNotifier<double>(0.025);
  final ValueNotifier<double> balanceLocal = ValueNotifier<double>(1250.0); // Mock starting local balance

  double get balanceUSD => balanceBTC.value * 65000.0; // Mock rate for BTC

  void depositBTC(double amount) {
    if (amount > 0) {
      balanceBTC.value += amount;
    }
  }

  void depositLocal(double amount) {
    if (amount > 0) {
      balanceLocal.value += amount;
    }
  }

  void withdraw(double amount) {
    if (amount > 0 && balanceBTC.value >= amount) {
      balanceBTC.value -= amount;
    }
  }
  
  bool hasSufficientFunds(double amount) {
    return balanceBTC.value >= amount;
  }
}
