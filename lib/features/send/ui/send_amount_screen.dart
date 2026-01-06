import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/service/user_lookup_service.dart';
import '../../../core/models/user_model.dart';

import 'comfirm_sheet.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class SendAmountScreen extends StatefulWidget {
  const SendAmountScreen({super.key});

  @override
  State<SendAmountScreen> createState() => _SendAmountScreenState();
}

class _SendAmountScreenState extends State<SendAmountScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final _lookupService = UserLookupService();

  AppUser? _recipient;
  String? _error;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _addressController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
  }

  bool get canContinue {
    final amount = double.tryParse(_amountController.text.trim());
    return _recipient != null && (amount != null && amount > 0);
  }

  bool get isAmountEnabled => _recipient != null;

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ----------------------------------
  // Resolve username to AppUser
  // ----------------------------------
  Future<void> _resolveRecipient(String input) async {
    final value = input.trim();

    if (!value.startsWith('@')) {
      setState(() {
        _error = 'Use a @username';
        _recipient = null;
      });
      return;
    }

    setState(() {
      _isResolving = true;
      _error = null;
    });

    final user = await _lookupService.findByUsername(value);

    if (!mounted) return;

    if (user == null) {
      setState(() {
        _error = 'User not found';
        _recipient = null;
        _isResolving = false;
      });
      return;
    }

    setState(() {
      _recipient = user;
      _isResolving = false;
    });
  }

  // ----------------------------------
  // Scan QR and normalize username
  // ----------------------------------
  Future<void> _scanQr() async {
    final result = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const _QrScannerScreen()));

    if (result != null && result.isNotEmpty) {
      final normalized = result.startsWith('@') ? result : '@$result';

      _addressController.text = normalized;
      await _resolveRecipient(normalized);
    }
  }

  // ----------------------------------
  // Show confirmation sheet
  // ----------------------------------
  void _showConfirmSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SendConfirmSheet(
        username: _recipient!.username,
        address: null,
        amount: _amountController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Payment'), elevation: 0),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------------- Recipient ----------------
            _InputSection(
              label: 'Recipient',
              child: TextField(
                controller: _addressController,
                style: const TextStyle(color: AppColors.textHigh),
                decoration: InputDecoration(
                  hintText: '@username',
                  errorText: _error,
                  suffixIcon: _isResolving
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: AppColors.primary,
                          ),
                          onPressed: _scanQr,
                        ),
                ),
                onChanged: (value) {
                  if (value.startsWith('@') && value.length > 2) {
                    _resolveRecipient(value);
                  }
                },
              ),
            ),

            // ---------------- Amount ----------------
            _InputSection(
              label: 'Amount',
              child: TextField(
                controller: _amountController,
                enabled: isAmountEnabled,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHigh,
                ),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  suffixText: 'BTC',
                  suffixStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            // ---------------- Description / Note ----------------
            _InputSection(
              label: 'Description (optional)',
              child: TextField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textHigh),
                decoration: const InputDecoration(
                  hintText: 'e.g. Rent, Lunch, Refund',
                ),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: canContinue ? _showConfirmSheet : null,
              child: const Text('Review Payment'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================
// UI helpers
// ===================================================

class _InputSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _InputSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMed,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: child,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ===================================================
// QR Scanner
// ===================================================

class _QrScannerScreen extends StatelessWidget {
  const _QrScannerScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: MobileScanner(
        onDetect: (capture) {
          for (final barcode in capture.barcodes) {
            final value = barcode.rawValue;
            if (value != null && value.isNotEmpty) {
              Navigator.pop(context, value);
              break;
            }
          }
        },
      ),
    );
  }
}
