import 'package:flutter/foundation.dart';

class WalletStore {
  // Singleton pattern
  static final WalletStore _instance = WalletStore._internal();
  factory WalletStore() => _instance;
  WalletStore._internal();

  // Observable balance
  final ValueNotifier<double> balanceBTC = ValueNotifier<double>(0.025);

  double get balanceUSD => balanceBTC.value * 65000.0; // Mock rate

  void deposit(double amount) {
    if (amount > 0) {
      balanceBTC.value += amount;
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
