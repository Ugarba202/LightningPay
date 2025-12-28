import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/widgets/glass_card.dart';
import '../../../../core/data/wallet_store.dart';
import '../../transaction/data/transaction_storage.dart';
import '../../transaction/model/transation_item.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/constant/contry_code.dart';
import 'package:uuid/uuid.dart';

class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  final _amountController = TextEditingController();
  bool _fromBTC = true;
  double _mockRate = 65000.0; // Default USD
  String _localCurrency = 'USD';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
    _loadUserCountry();
  }

  Future<void> _loadUserCountry() async {
    final countryName = await AuthStorage.getCountry();
    if (countryName != null) {
      final country = Country.getByName(countryName);
      if (country != null) {
        setState(() {
          _localCurrency = country.currencyCode;
          // Set mock rate based on currency
          _mockRate = _getRateForCurrency(_localCurrency);
        });
      }
    }
  }

  double _getRateForCurrency(String code) {
    final rates = {
      'NGN': 105000000.0, // 1 BTC ~ 105M NGN
      'PKR': 18000000.0,   // 1 BTC ~ 18M PKR
      'EUR': 60000.0,
      'GBP': 52000.0,
      'INR': 5500000.0,
      'USD': 65000.0,
    };
    return rates[code] ?? 65000.0;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onConvert() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Mock delay

    WalletStore().convert(amount: amount, fromBTC: _fromBTC, rate: _mockRate);

    // Record Transaction
    await TransactionStorage.addTransaction(TransactionItem(
      title: _fromBTC ? 'BTC to $_localCurrency' : '$_localCurrency to BTC',
      date: DateTime.now(),
      amount: amount,
      currency: _fromBTC ? 'BTC' : _localCurrency,
      type: TransactionType.conversion,
      status: TransactionStatus.completed,
      txId: const Uuid().v4(),
      address: 'Internal Exchange',
      fee: '0.00',
    ));

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversion Successful!')),
      );
    }
  }

  void _toggleDirection() {
    setState(() {
      _fromBTC = !_fromBTC;
      _amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Convert Assets'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Direction Card
            GlassCard(
              padding: const EdgeInsets.all(20),
              color: Colors.white.withOpacity(0.03),
              child: Column(
                children: [
                  _CurrencyRow(
                    label: 'From',
                    currency: _fromBTC ? 'BTC' : _localCurrency,
                    icon: _fromBTC ? Icons.currency_bitcoin_rounded : Icons.attach_money_rounded,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: IconButton(
                      onPressed: _toggleDirection,
                      icon: const Icon(Icons.swap_vert_rounded, color: AppColors.primary, size: 32),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  _CurrencyRow(
                    label: 'To',
                    currency: _fromBTC ? _localCurrency : 'BTC',
                    icon: _fromBTC ? Icons.attach_money_rounded : Icons.currency_bitcoin_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Amount Input
            _InputSection(
              label: 'Amount to Convert',
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textHigh),
                decoration: InputDecoration(
                  hintText: '0.00',
                  suffixText: _fromBTC ? 'BTC' : _localCurrency,
                  suffixStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Estimation Card
            if (_amountController.text.isNotEmpty)
              GlassCard(
                padding: const EdgeInsets.all(20),
                color: AppColors.primary.withOpacity(0.05),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Exchange Rate',
                      value: '1 BTC ≈ ${_localCurrency == 'USD' ? '\$' : ''}${_mockRate.toStringAsFixed(0)} $_localCurrency',
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Service Fee',
                      value: 'Free (Promo)',
                      valueColor: AppColors.success,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.border, thickness: 0.5),
                    ),
                    _DetailRow(
                      label: 'You Will Receive',
                      value: _fromBTC 
                          ? '${_localCurrency == 'USD' ? '\$' : ''}${((double.tryParse(_amountController.text) ?? 0) * _mockRate).toStringAsFixed(_localCurrency == 'USD' ? 2 : 0)} $_localCurrency'
                          : '${((double.tryParse(_amountController.text) ?? 0) / _mockRate).toStringAsFixed(8).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")} BTC',
                      isBold: true,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: _isLoading || _amountController.text.isEmpty ? null : _onConvert,
              child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                  : const Text('Confirm Conversion'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  final String label;
  final String currency;
  final IconData icon;

  const _CurrencyRow({required this.label, required this.currency, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: AppColors.textLow, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(currency, style: const TextStyle(color: AppColors.textHigh, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
      ],
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
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textLow,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _DetailRow({required this.label, required this.value, this.valueColor, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textMed, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isBold ? AppColors.primary : AppColors.textHigh),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
