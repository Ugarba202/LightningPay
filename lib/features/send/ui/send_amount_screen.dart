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

  @override
  void initState() {
    super.initState();
    _addressController.addListener(() => setState(() {}));
    _amountController.addListener(
      () => setState(() {}),
    ); // Listen to amount changes
  }

  bool get canContinue {
    final amount = double.tryParse(_amountController.text.trim());
    return _addressController.text.trim().isNotEmpty &&
        (amount != null && amount > 0);
  }

  bool get isAmountEnabled => _addressController.text.trim().isNotEmpty;

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
      _showConfirmSheet();
    }
  }

  void _showConfirmSheet() {
    final addressText = _addressController.text.trim();
    // Simple heuristic: if it contains spaces or is short, treat as username?
    // Or just treat everything as address unless it looks like a username?
    // Requirement says: "Any input that is not a standard wallet address format ... will be treated as a Username"
    // Let's check length for now. Bitcoin addresses are usually 26-35 characters.
    // Be generous and say if length < 25, it's a username. Or if it doesn't start with 1, 3, or bc1?

    // For this mock:
    final isUsername = addressText.length < 25;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SendConfirmSheet(
        address: isUsername ? null : addressText,
        username: isUsername ? addressText : null,
        amount: _amountController.text.trim(),
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
            _InputSection(
              label: 'Recipient',
              child: TextField(
                controller: _addressController,
                style: const TextStyle(color: AppColors.textHigh),
                decoration: InputDecoration(
                  hintText: 'Address or Username',
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppColors.primary,
                    ),
                    onPressed: _scanQr,
                  ),
                ),
              ),
            ),
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
            const SizedBox(height: 40),
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textMed,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
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

  @override
  void initState() {
    super.initState();
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanWindowSize = const Size(260, 260);
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            scanWindow: Rect.fromCenter(
              center: MediaQuery.of(context).size.center(Offset.zero),
              width: scanWindowSize.width,
              height: scanWindowSize.height,
            ),
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final raw = barcodes.first.rawValue ?? '';
                if (raw.isNotEmpty && raw != _scanned) {
                  setState(() => _scanned = raw);
                  _controller.stop();
                  Navigator.of(context).pop(raw);
                }
              }
            },
          ),
          CustomPaint(
            painter: _ScannerOverlayPainter(
              borderColor: AppColors.primary,
              borderRadius: 24,
              borderWidth: 3,
              overlayColor: Colors.black,
              scanWindowSize: scanWindowSize,
            ),
            child: Container(),
          ),
          Positioned(
            bottom: 80,
            left: 24,
            right: 24,
            child: Text(
              'Align the QR code within the frame to scan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;
  final Color overlayColor;
  final Size scanWindowSize;

  _ScannerOverlayPainter({
    required this.borderColor,
    required this.borderRadius,
    required this.borderWidth,
    required this.overlayColor,
    required this.scanWindowSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rect = Rect.fromCenter(
      center: center,
      width: scanWindowSize.width,
      height: scanWindowSize.height,
    );

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)));

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, overlayPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
