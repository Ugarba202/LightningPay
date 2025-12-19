import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/transation_item.dart';

class TransactionStorage {
  static const _kTransactions = 'transactions_list_v1';

  static Future<List<TransactionItem>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kTransactions) ?? [];
    final items = raw
        .map((s) {
          try {
            return TransactionItem.fromJson(
              jsonDecode(s) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<TransactionItem>()
        .toList();

    // Sort by date desc
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  static Future<void> addTransaction(TransactionItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kTransactions) ?? [];
    list.add(jsonEncode(item.toJson()));
    await prefs.setStringList(_kTransactions, list);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTransactions);
  }
}
