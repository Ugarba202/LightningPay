import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/service/convert_service.dart';
import '../../../core/service/rate_service.dart';

class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  final _btcController = TextEditingController();
  final _convertService = ConvertService();
  final _rateService = RateService();

  double _localPreview = 0;
  bool _isLoading = false;
  String _currency = 'NGN'; // will later come from user profile

  void _updatePreview(String value) {
    final btc = double.tryParse(value);
    if (btc == null || btc <= 0) {
      setState(() => _localPreview = 0);
      return;
    }

    setState(() {
      _localPreview = _rateService.btcToLocal(
        btcAmount: btc,
        currency: _currency,
      );
    });
  }

  Future<void> _convert() async {
    final btc = double.tryParse(_btcController.text);
    if (btc == null || btc <= 0) return;

    setState(() => _isLoading = true);

    try {
      await _convertService.convertBtcToLocal(btcAmount: btc);

      if (!mounted) return;
      Navigator.pop(context); // back to dashboard
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _btcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Convert BTC')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'BTC Amount',
              style: TextStyle(
                color: AppColors.textMed,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _btcController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: _updatePreview,
              decoration: const InputDecoration(
                hintText: '0.00',
                suffixText: 'BTC',
              ),
            ),
            const SizedBox(height: 32),

            // 🔍 Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'You will receive',
                    style: TextStyle(color: AppColors.textMed),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_localPreview.toStringAsFixed(2)} $_currency',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _isLoading ? null : _convert,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Convert'),
            ),
          ],
        ),
      ),
    );
  }
}
