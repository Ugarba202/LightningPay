import 'package:flutter/material.dart';
import 'package:breez_sdk/bridge_generated.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/service/user_lookup_service.dart';
import '../../../core/service/breeze_service.dart';
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
  String? _bolt11;
  String? _error;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _addressController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
  }

  bool get canContinue {
    if (_bolt11 != null) return true;
    final amount = double.tryParse(_amountController.text.trim());
    return _recipient != null && (amount != null && amount > 0);
  }

  bool get isAmountEnabled => _recipient != null && _bolt11 == null;

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ----------------------------------
  // Resolve username or Bolt11
  // ----------------------------------
  Future<void> _processInput(String input) async {
    final value = input.trim();

    if (value.toLowerCase().startsWith('lnbc')) {
      _processBolt11(value);
      return;
    }

    if (!value.startsWith('@')) {
      setState(() {
        _error = 'Use a @username or Lightning Invoice';
        _recipient = null;
        _bolt11 = null;
      });
      return;
    }

    setState(() {
      _isResolving = true;
      _error = null;
      _bolt11 = null;
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

  Future<void> _processBolt11(String bolt11) async {
    setState(() {
      _isResolving = true;
      _error = null;
      _recipient = null;
    });

    try {
      final invoice = await BreezeService.instance.parseInvoice(bolt11);
      if (!mounted) return;

      setState(() {
        _bolt11 = bolt11;
        _amountController.text = (invoice.amountMsat ~/ 1000).toString();
        _noteController.text = invoice.description ?? '';
        _isResolving = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Invalid Lightning Invoice';
        _isResolving = false;
      });
    }
  }

  // ----------------------------------
  // Scan QR and normalize input
  // ----------------------------------
  Future<void> _scanQr() async {
    final result = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const _QrScannerScreen()));

    if (result != null && result.isNotEmpty) {
      _addressController.text = result;
      await _processInput(result);
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
        username: _recipient?.username,
        bolt11: _bolt11,
        address: _addressController.text.trim(),
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
                  hintText: '@username or lnbc...',
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
                  // Clear previous state while typing
                  setState(() {
                    _recipient = null;
                    _bolt11 = null;
                    _error = null;
                  });

                  if ((value.startsWith('@') && value.length > 2) ||
                      value.toLowerCase().startsWith('lnbc')) {
                    _processInput(value);
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
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: _bolt11 != null ? 'sats' : 'BTC',
                  suffixStyle: const TextStyle(
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
                enabled: _bolt11 == null,
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: MobileScanner(
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
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Align QR code within the frame',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
