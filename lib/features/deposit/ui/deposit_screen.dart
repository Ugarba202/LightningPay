import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
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
    
    Navigator.pop(context); // Go back to dashboard handling success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deposit Successful! Balance Updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Deposit Funds')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Purpose Selection
            Text('Purpose', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPurpose,
                  isExpanded: true,
                  items: _purposes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) => setState(() => _selectedPurpose = val!),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Currency Selection
            Text('Currency', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  isExpanded: true,
                  items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _selectedCurrency = val!),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Amount Input
            Text('Amount', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter amount',
                suffixText: _selectedCurrency,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 32),

            // Summary
            if (_amountController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Deposit Method:'),
                        const Text('Mock Bank Transfer'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fee:'),
                        const Text('0.00'),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading || _amountController.text.isEmpty ? null : _onDeposit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Confirm Deposit'),
            ),
          ],
        ),
      ),
    );
  }
}
