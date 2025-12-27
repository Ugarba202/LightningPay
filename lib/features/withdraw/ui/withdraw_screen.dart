import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../logic/withdraw_logic.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _logic = WithdrawLogic();
  final _amountController = TextEditingController();
  final _destinationController = TextEditingController();
  
  String _selectedType = 'To Bank Account';
  final List<String> _types = ['To Bank Account', 'To Another User (P2P)'];

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _onWithdraw() async {
    setState(() => _error = null);

    if (!_logic.validateAmount(_amountController.text)) {
      setState(() => _error = "Please enter a valid amount");
      return;
    }

    final balanceError = _logic.checkBalance(_amountController.text);
    if (balanceError != null) {
       setState(() => _error = balanceError);
       return;
    }

    if (_destinationController.text.isEmpty) {
      setState(() => _error = "Please enter destination details");
      return;
    }

    setState(() => _isLoading = true);

    await _logic.processWithdraw(
      amount: _amountController.text,
      type: _selectedType,
      destination: _destinationController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    
    Navigator.pop(context); // Go back to dashboard handing success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Withdraw Successful! Balance Updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Withdraw Funds')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type Selection
            Text('Withdraw Type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Destination Input
            Text(
              _selectedType == 'To Bank Account' ? 'Account Number' : 'Username (@handle)', 
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                hintText: _selectedType == 'To Bank Account' ? 'Enter Bank Account Number' : 'Enter Username',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // Amount Input
            Text('Amount (BTC)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter amount to withdraw',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                errorText: _error,
              ),
              onChanged: (_) => setState(() => _error = null),
            ),

            const SizedBox(height: 32),

            // Summary
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
                      const Text('Withdraw Method:'),
                      Text(_selectedType == 'To Bank Account' ? 'Standard Transfer' : 'Instant P2P'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Processing Time:'),
                      Text(_selectedType == 'To Bank Account' ? '1-2 Days' : 'Instant'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _onWithdraw,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.redAccent, // Red for outflow
              ),
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Confirm Withdraw'),
            ),
          ],
        ),
      ),
    );
  }
}
