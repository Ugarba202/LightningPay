import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/widgets/glass_card.dart';
import '../logic/deposit_logic.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _logic = DepositLogic();
  final _amountController = TextEditingController();
  
  String _selectedPurpose = 'Savings';
  final List<String> _purposes = ['Send to friend', 'Savings', 'Household', 'School fees'];

  String _selectedCurrency = 'USD';
  final List<String> _currencies = ['BTC', 'USD', 'NGN', 'EUR'];

  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onDeposit() async {
    if (!_logic.validateAmount(_amountController.text)) return;

    setState(() => _isLoading = true);

    await _logic.processDeposit(
      amount: _amountController.text,
      currency: _selectedCurrency,
      purpose: _selectedPurpose,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deposit Successful! Balance Updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Funds'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InputSection(
              label: 'Purpose of Deposit',
              child: _SelectionContainer(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPurpose,
                    dropdownColor: AppColors.surfaceDark,
                    isExpanded: true,
                    items: _purposes.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p, style: const TextStyle(color: AppColors.textHigh)),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedPurpose = val!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _InputSection(
              label: 'Source Currency',
              child: _SelectionContainer(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCurrency,
                    dropdownColor: AppColors.surfaceDark,
                    isExpanded: true,
                    items: _currencies.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, style: const TextStyle(color: AppColors.textHigh, fontWeight: FontWeight.bold)),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedCurrency = val!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _InputSection(
              label: 'Amount to Deposit',
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textHigh),
                decoration: InputDecoration(
                  hintText: '0.00',
                  suffixText: _selectedCurrency,
                  suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            const SizedBox(height: 32),

            if (_amountController.text.isNotEmpty)
              GlassCard(
                padding: const EdgeInsets.all(20),
                color: AppColors.primary.withOpacity(0.05),
                child: Column(
                  children: [
                    _SummaryRow(label: 'Deposit Method', value: 'Bank Transfer'),
                    const SizedBox(height: 12),
                    _SummaryRow(label: 'Processing Fee', value: '0.00 $_selectedCurrency'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.border, thickness: 0.5),
                    ),
                    _SummaryRow(
                      label: "You'll Receive",
                      value: '${_amountController.text} $_selectedCurrency',
                      isBold: true,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: _isLoading || _amountController.text.isEmpty ? null : _onDeposit,
              child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                : const Text('Confirm Deposit'),
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
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
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

class _SelectionContainer extends StatelessWidget {
  final Widget child;

  const _SelectionContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: child,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textMed, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: isBold ? AppColors.primary : AppColors.textHigh,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}

