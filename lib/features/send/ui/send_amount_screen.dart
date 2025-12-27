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
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Mock Currency Data
  final List<Map<String, dynamic>> _currencies = [
    {'code': 'BTC', 'name': 'Bitcoin', 'rate': 1.0, 'flag': '₿'},
    {'code': 'USD', 'name': 'US Dollar', 'rate': 65000.0, 'flag': '🇺🇸'},
    {'code': 'NGN', 'name': 'Nigerian Naira', 'rate': 100000000.0, 'flag': '🇳🇬'}, // Mock rate
    {'code': 'EUR', 'name': 'Euro', 'rate': 60000.0, 'flag': '🇪🇺'},
    {'code': 'GBP', 'name': 'British Pound', 'rate': 52000.0, 'flag': '🇬🇧'},
  ];

  late Map<String, dynamic> _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = _currencies[1]; // Default to USD for "cross-border" feel
    _addressController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {})); // Listen to amount changes
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
    _reasonController.dispose();
    _noteController.dispose();
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
        reason: _reasonController.text.trim(),
        note: _noteController.text.trim(),
      ),
    );
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
            Text(
              'Recipient (Address or Username)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter address or username',
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

            const SizedBox(height: 24),

            // Country / Currency Selector
            Text(
              'Recipient Currency',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  value: _selectedCurrency,
                  isExpanded: true,
                  items: _currencies.map((currency) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: currency,
                      child: Row(
                        children: [
                          Text(
                            currency['flag'],
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currency['code'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                currency['name'],
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCurrency = value;
                      });
                    }
                  },
                ),
              ),
            ),
            
            if (_selectedCurrency['code'] != 'BTC') ...[
               const SizedBox(height: 8),
               Text(
                 'Exchange Rate: 1 BTC ≈ ${_selectedCurrency['rate']} ${_selectedCurrency['code']}',
                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
                   color: AppColors.textSecondary,
                 ),
               ),
            ],

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
              enabled: isAmountEnabled,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: isAmountEnabled
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
            
            // Estimated Receive Amount
            if (_amountController.text.isNotEmpty && _selectedCurrency['code'] != 'BTC') ...[
               const SizedBox(height: 8),
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: AppColors.primary.withOpacity(0.05),
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Text('Recipient Receives:'),
                     Text(
                       '${(double.tryParse(_amountController.text) ?? 0 * (_selectedCurrency['rate'] as double)).toStringAsFixed(2)} ${_selectedCurrency['code']}',
                       style: const TextStyle(
                         fontWeight: FontWeight.bold,
                         fontSize: 16,
                       ),
                     ),
                   ],
                 ),
               ),
            ],
            
            // Estimated Receive Amount


            const SizedBox(height: 24),

            Text(
              'Transaction Details (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            // Reason
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Reason (e.g. Dinner, Rent)',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Note
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Add a note',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
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
              onPressed: canContinue
                  ? () {
                      _showConfirmSheet();
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
