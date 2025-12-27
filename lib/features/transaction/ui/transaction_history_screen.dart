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
    final filtered = _transactions.where((t) => _filter == TransactionType.lightning || t.type == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Selector
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  _FilterTab(
                    label: 'Sent',
                    isSelected: _filter == TransactionType.sent,
                    onTap: () => setState(() => _filter = TransactionType.sent),
                  ),
                  _FilterTab(
                    label: 'Received',
                    isSelected: _filter == TransactionType.received,
                    onTap: () => setState(() => _filter = TransactionType.received),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_rounded, size: 64, color: AppColors.textLow),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions found',
                              style: TextStyle(color: AppColors.textMed, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
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
                              borderRadius: BorderRadius.circular(20),
                              child: TransactionTile(transaction: tx),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? Colors.white : AppColors.textMed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

