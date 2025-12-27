import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../model/transation_item.dart';
import '../../../core/themes/widgets/glass_card.dart';

class TransactionReceiptScreen extends StatelessWidget {
  final TransactionItem transaction;

  const TransactionReceiptScreen({super.key, required this.transaction});

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Transaction Receipt',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(height: 20),
                pw.SizedBox(height: 20),
                _buildPdfRow('Transaction ID:', transaction.txId),
                if (transaction.username != null &&
                    transaction.username!.isNotEmpty)
                  _buildPdfRow('Username:', transaction.username!),
                _buildPdfRow('To:', transaction.address),
                _buildPdfRow('Amount:', '${transaction.amount} BTC'),
                _buildPdfRow('Network Fee:', transaction.fee),
                if (transaction.reason != null &&
                    transaction.reason!.isNotEmpty)
                  _buildPdfRow('Reason:', transaction.reason!),
                if (transaction.note != null && transaction.note!.isNotEmpty)
                  _buildPdfRow('Note:', transaction.note!),
                _buildPdfRow(
                  'Status:',
                  transaction.status.toString().split('.').last,
                ),
                _buildPdfRow('Date:', transaction.date.toLocal().toString()),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  Future<void> _printReceipt(BuildContext context) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => _generatePdf(format),
    );
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    try {
      final bytes = await _generatePdf(PdfPageFormat.a4);
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'receipt_${transaction.txId.length >= 8 ? transaction.txId.substring(0, 8) : transaction.txId}.pdf',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download not supported on this device')),
      );
    }
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 16)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Digital Receipt'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.bgDark.withOpacity(0.8),
                AppColors.bgDark.withOpacity(0),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.primary),
            onPressed: () async {
              final receiptText =
                  '''
Transaction Receipt
ID: ${transaction.txId}
To: ${transaction.address}
${transaction.username != null ? 'Recipient: ${transaction.username}\n' : ''}Amount: ${transaction.amount} ${transaction.currency}
Status: ${transaction.status.name.toUpperCase()}
Date: ${transaction.date.toLocal()}''';
              try {
                await Share.share(receiptText, subject: 'LightningPay Receipt');
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Sharing failed')));
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [AppColors.primary.withOpacity(0.05), AppColors.bgDark],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
          child: Column(
            children: [
              Hero(
                tag: 'receipt_icon',
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    () {
                      switch (transaction.type) {
                        case TransactionType.sent: return Icons.north_east_rounded;
                        case TransactionType.received: return Icons.south_west_rounded;
                        case TransactionType.lightning: return Icons.bolt_rounded;
                        case TransactionType.deposit: return Icons.add_circle_outline_rounded;
                        case TransactionType.withdrawal: return Icons.remove_circle_outline_rounded;
                        case TransactionType.conversion: return Icons.swap_horiz_rounded;
                      }
                    }(),
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                () {
                  switch (transaction.type) {
                    case TransactionType.sent: return 'Proof of Payment';
                    case TransactionType.received: return 'Payment Received';
                    case TransactionType.lightning: return 'Lightning Receipt';
                    case TransactionType.deposit: return 'Deposit Receipt';
                    case TransactionType.withdrawal: return 'Withdrawal Receipt';
                    case TransactionType.conversion: return 'Conversion Receipt';
                  }
                }(),
                style: const TextStyle(
                  color: AppColors.textHigh,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  () {
                    switch (transaction.type) {
                      case TransactionType.sent:
                      case TransactionType.received:
                      case TransactionType.lightning:
                        return 'Verified on Bitcoin Blockchain';
                      case TransactionType.deposit:
                      case TransactionType.withdrawal:
                        return 'Verified via Bank Network';
                      case TransactionType.conversion:
                        return 'Internal Ledger Verified';
                    }
                  }(),
                  style: const TextStyle(color: AppColors.textMed, fontSize: 12),
                ),
              ),

              const SizedBox(height: 40),

              // Glassmorphic Receipt Card
              GlassCard(
                padding: const EdgeInsets.all(24),
                color: Colors.white.withOpacity(0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DetailSection(
                      label: 'Transaction ID',
                      value: transaction.txId,
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: transaction.txId),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ID copied')),
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: AppColors.border, thickness: 0.5),
                    ),

                    _ReceiptRow(
                      label: 'Date & Time',
                      value: transaction.date.toLocal().toString().substring(
                        0,
                        19,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ReceiptRow(
                      label: 'Destination',
                      value: transaction.address.length > 12
                          ? '${transaction.address.substring(0, 12)}...'
                          : transaction.address,
                    ),
                    if (transaction.username != null) ...[
                      const SizedBox(height: 16),
                      _ReceiptRow(
                        label: 'Recipient',
                        value: transaction.username!,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _ReceiptRow(label: 'Network Fee', value: transaction.fee),
                    const SizedBox(height: 16),
                    _ReceiptRow(
                      label: 'Status',
                      valueWidget: _StatusBadge(status: transaction.status),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: AppColors.border, thickness: 0.5),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            color: AppColors.textHigh,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${transaction.amount} ${transaction.currency}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadReceipt(context),
                      icon: const Icon(Icons.file_download_rounded, size: 20),
                      label: const Text('Save PDF'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.border.withOpacity(0.3),
                        ),
                        foregroundColor: AppColors.textHigh,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _printReceipt(context),
                      icon: const Icon(Icons.print_rounded, size: 20),
                      label: const Text('Print'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: AppColors.textLow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DetailSection({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textLow,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textHigh,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.copy_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _ReceiptRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textMed, fontSize: 13)),
        valueWidget ??
            Text(
              value!,
              style: const TextStyle(
                color: AppColors.textHigh,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
      ],
    );
  }
}

// Removed old _Row class - replaced by _ReceiptRow

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
