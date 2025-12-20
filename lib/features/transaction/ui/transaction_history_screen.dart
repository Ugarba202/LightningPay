import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../data/transaction_storage.dart';
import '../model/transation_item.dart';
import 'transaction_receipt_screen.dart';
import 'transaction_tile.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<TransactionItem> _transactions = [];
  TransactionType _filter = TransactionType.sent;
  bool _loading = true;

  Future<void> _load() async {
    final items = await TransactionStorage.getTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = items;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _transactions.where((t) => t.type == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Transactions'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tab-like selector
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = TransactionType.sent),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _filter == TransactionType.sent
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Sent (${_transactions.where((t) => t.type == TransactionType.sent).length})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _filter == TransactionType.sent
                                ? Colors.black
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _filter = TransactionType.received),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _filter == TransactionType.received
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Received (${_transactions.where((t) => t.type == TransactionType.received).length})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _filter == TransactionType.received
                                ? Colors.black
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final tx = filtered[index];
                          return InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TransactionReceiptScreen(transaction: tx),
                              ),
                            ),
                            child: TransactionTile(transaction: tx),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
