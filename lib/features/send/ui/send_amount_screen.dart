import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
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

  bool get _isAmountEnabled => _addressController.text.trim().isNotEmpty;
  bool get _canContinue {
    final amount = double.tryParse(_amountController.text.trim());
    return _addressController.text.trim().isNotEmpty &&
        (amount != null && amount > 0);
  }

  @override
  void initState() {
    super.initState();
    _addressController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final result = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const _QrScannerScreen()));

    if (result != null && result.isNotEmpty) {
      setState(() {
        _addressController.text = result;
      });

      if (!mounted) return;
      // Immediately show confirm sheet (user requested Send to push to confirm)
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => SendConfirmSheet(
          address: _addressController.text.trim(),
          amount: _amountController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Send Bitcoin')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // Wallet Address input
            Text('Recipient', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter wallet address',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Divider with label
            Row(
              children: [
                const Expanded(child: Divider()),
                const SizedBox(width: 12),
                Text(
                  'or Scan QR code',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 12),

            // Scan QR button below the address field (full-width, larger)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _scanQr,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text('Amount', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            // Amount input (disabled until address provided)
            TextField(
              controller: _amountController,
              enabled: _isAmountEnabled,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: _isAmountEnabled
                    ? 'Enter amount (BTC)'
                    : 'Enter address first',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 24),

            // Fee preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const Text('Network Fee'), const Text('0.0001 BTC')],
              ),
            ),

            const Spacer(),

            // Continue button
            ElevatedButton(
              onPressed: _canContinue
                  ? () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => SendConfirmSheet(
                          address: _addressController.text.trim(),
                          amount: _amountController.text.trim(),
                        ),
                      );
                    }
                  : null,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Simple QR scanner screen using mobile_scanner package
// -------------------------------------------------------------

class _QrScannerScreen extends StatefulWidget {
  const _QrScannerScreen();

  @override
  State<_QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<_QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  String? _scanned;

  // Overlay target size
  static const double _overlaySize = 260;

  @override
  void initState() {
    super.initState();
    // Ensure camera starts as soon as scanner opens
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final raw = barcodes.first.rawValue ?? '';
      if (raw.isNotEmpty && raw != _scanned) {
        setState(() {
          _scanned = raw;
        });
        // Pause scanning so the user can review before sending
        _controller.stop();
      }
    }
  }

  void _onSend() {
    if (_scanned != null && _scanned!.isNotEmpty) {
      Navigator.of(context).pop(_scanned);
    }
  }

  void _onRescan() {
    setState(() => _scanned = null);
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('QR Scanner'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // White background so only the camera window appears active
          Container(color: Colors.white),

          // Centered camera window with black background and rounded border
          Center(
            child: Container(
              width: _overlaySize,
              height: _overlaySize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
              ),
            ),
          ),

          // Bottom panel with scanned info and Send button
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show scanned text or hint
                if (_scanned != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Scanned address',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _scanned!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _onSend,
                                child: const Text('Send'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: _onRescan,
                              child: const Text('Rescan'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Point the camera at a QR code',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: null,
                            child: const Text(
                              'Waiting for code...',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                              side: MaterialStateProperty.all(
                                const BorderSide(color: Colors.white38),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
