import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/service/transaction_service.dart';
import '../../../core/themes/app_colors.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txService = TransactionService();
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transactions'),
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Colors.orange,
            labelColor: Colors.orange,
            unselectedLabelColor: AppColors.textLow,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Sent'),
              Tab(text: 'Received'),
              Tab(text: 'Deposit'),
              Tab(text: 'Withdraw'),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: txService.transactionsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorWidget(error: snapshot.error.toString());
            }

            final allDocs = snapshot.data?.docs ?? [];

            if (allDocs.isEmpty) {
              return const Center(
                child: Text('No transactions yet',
                    style: TextStyle(color: AppColors.textMed)),
              );
            }

            return TabBarView(
              physics: const BouncingScrollPhysics(),
              children: [
                _TransactionList(docs: allDocs, currentUid: currentUid), // All
                _TransactionList(
                  docs: allDocs.where((d) {
                    final data = d.data();
                    return data['type'] == 'sent' && data['senderId'] == currentUid;
                  }).toList(),
                  currentUid: currentUid,
                ), // Sent
                _TransactionList(
                  docs: allDocs.where((d) {
                    final data = d.data();
                    return data['receiverId'] == currentUid && 
                           (data['type'] == 'received' || data['type'] == 'sent');
                  }).toList(),
                  currentUid: currentUid,
                ), // Received
                _TransactionList(
                  docs: allDocs.where((d) => d.data()['type'] == 'deposit' && d.data()['receiverId'] == currentUid).toList(),
                  currentUid: currentUid,
                ), // Deposit
                _TransactionList(
                  docs: allDocs.where((d) => d.data()['type'] == 'withdraw' && d.data()['senderId'] == currentUid).toList(),
                  currentUid: currentUid,
                ), // Withdraw
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  final String currentUid;

  const _TransactionList({required this.docs, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return const Center(
        child: Text('No transactions in this category',
            style: TextStyle(color: AppColors.textMed)),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final data = docs[index].data();

        final type = data['type'] ?? '';
        final senderId = data['senderId'] ?? '';
        final receiverId = data['receiverId'] ?? '';
        final amountBtc = (data['amountBtc'] ?? 0).toDouble();
        final amountLocal = (data['amountLocal'] ?? 0).toDouble();
        final currency = data['currency'] ?? '';
        final createdAt = data['createdAt'] as Timestamp?;
        final note = data['note'];

        String title = 'Transaction';
        IconData icon = Icons.help_outline_rounded;
        Color iconColor = AppColors.textMed;
        String amountStr = '';
        bool isPositive = false;

        // 🟢 Logic to determine Sent vs Received correctly
        if (type == 'sent' || type == 'received') {
          if (receiverId == currentUid) {
            title = 'Received BTC';
            icon = Icons.call_received_rounded;
            iconColor = AppColors.success;
            amountStr = '+${amountBtc.toStringAsFixed(6)} BTC';
            isPositive = true;
          } else if (senderId == currentUid) {
            title = 'Sent BTC';
            icon = Icons.call_made_rounded;
            iconColor = AppColors.error;
            amountStr = '-${amountBtc.toStringAsFixed(6)} BTC';
            isPositive = false;
          } else {
            // Fallback for cases where neither match (should be rare with stream filters)
            title = 'BTC Transaction';
            icon = Icons.swap_horiz_rounded;
            amountStr = '${amountBtc.toStringAsFixed(6)} BTC';
          }
        } else if (type == 'deposit') {
          title = 'Deposited Funds';
          icon = Icons.add_circle_outline_rounded;
          iconColor = AppColors.success;
          amountStr = '+$amountLocal $currency';
          isPositive = true;
        } else if (type == 'withdraw') {
          title = 'Withdrew Funds';
          icon = Icons.remove_circle_outline_rounded;
          iconColor = AppColors.error;
          amountStr = '-$amountLocal $currency';
          isPositive = false;
        } else if (type == 'convert') {
          title = 'Converted BTC';
          icon = Icons.swap_horiz_rounded;
          iconColor = AppColors.primary;
          amountStr = '${amountBtc.toStringAsFixed(6)} BTC';
          isPositive = false;
        }

        return _TransactionTile(
          title: title,
          subtitle: note ?? 'Bitcoin transaction',
          amount: amountStr,
          isPositive: isPositive,
          icon: icon,
          iconColor: iconColor,
          date: createdAt?.toDate(),
        );
      },
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  const _ErrorWidget({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Failed to load transactions',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textHigh,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This usually happens if a Firestore index is missing. Check your console for a setup link.\n\nError: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMed),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;
  final IconData icon;
  final Color iconColor;
  final DateTime? date;

  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
    required this.icon,
    required this.iconColor,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textHigh,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMed,
                    fontSize: 13,
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${date!.day}/${date!.month}/${date!.year}',
                    style: const TextStyle(
                      color: AppColors.textLow,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color:
                  isPositive ? AppColors.success : AppColors.textHigh,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
