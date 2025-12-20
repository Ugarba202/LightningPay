import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lighting_pay/core/themes/app_colors.dart' show AppColors;
import 'package:lighting_pay/features/transaction/model/transation_item.dart' show TransactionItem, TransactionStatus;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

// import '../../../core/themes/app_colors.dart';
// import '../model/transation_item.dart';

class TransactionReceiptScreen extends StatelessWidget {
  final TransactionItem transaction;

  const TransactionReceiptScreen({super.key, required this.transaction});

  Future<void> _printReceipt(BuildContext context) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Transaction Receipt',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Divider(height: 20),
                pw.SizedBox(height: 20),
                _buildPdfRow('Transaction ID:', transaction.txId),
                _buildPdfRow('To:', transaction.address),
                _buildPdfRow('Amount:', '${transaction.amount} BTC'),
                _buildPdfRow('Network Fee:', transaction.fee),
                _buildPdfRow('Status:',
                    transaction.status.toString().split('.').last),
                _buildPdfRow(
                    'Date:', transaction.date.toLocal().toString()),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 16)),
          pw.Text(value,
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Receipt'),
        actions: [
          IconButton(icon: const Icon(Icons.share),
            onPressed: () async {
              final receiptText =
                  '''
Transaction Receipt
-------------------
ID: ${transaction.txId}
To: ${transaction.address}
Amount: ${transaction.amount} BTC
Fee: ${transaction.fee}
Status: ${transaction.status.toString().split('.').last}
Date: ${transaction.date.toLocal().toString()}''';
              // ignore: deprecated_member_use
              try {
                await Share.share(receiptText, subject: 'Transaction Receipt');
              } on PlatformException {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sharing is not available on this device.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(24),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction ID',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    transaction.txId,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Divider(height: 20),
                  _Row(
                    label: 'To',
                    value: transaction.address,
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: transaction.address),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address copied to clipboard'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _Row(label: 'Amount', value: '${transaction.amount} BTC'),
                  const SizedBox(height: 8),
                  _Row(label: 'Network Fee', value: transaction.fee),
                  const SizedBox(height: 8),
                  _Row(
                    label: 'Status',
                    valueWidget: _StatusBadge(status: transaction.status),
                  ),
                  const SizedBox(height: 8),
                  _Row(
                    label: 'Date',
                    value: transaction.date.toLocal().toString(),
                  ),
                ],
              ),
            ),

            const Spacer(),

          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print'),
                onPressed: () => _printReceipt(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy TX ID'),
                onPressed: () async {
                  try {
                    await Clipboard.setData(
                      ClipboardData(text: transaction.txId),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction ID copied to clipboard'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to copy')),
                    );
                  }
                },
              ),
            ),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final VoidCallback? onTap;

  const _Row({required this.label, this.value, this.valueWidget, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.black54)),
            Flexible(
              child:
                  valueWidget ??
                  Text(
                    value ?? '',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    switch (status) {
      case TransactionStatus.completed:
        text = 'Completed';
        color = AppColors.success;
        break;
      case TransactionStatus.pending:
        text = 'Pending';
        color = Colors.orange;
        break;
      case TransactionStatus.failed:
        text = 'Failed';
        color = AppColors.error;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
