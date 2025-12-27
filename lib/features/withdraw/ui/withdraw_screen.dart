import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/widgets/glass_card.dart';
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
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Withdraw Successful! Balance Updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Funds'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InputSection(
              label: 'Withdrawal Method',
              child: _SelectionContainer(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    dropdownColor: AppColors.surfaceDark,
                    isExpanded: true,
                    items: _types.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t, style: const TextStyle(color: AppColors.textHigh)),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _InputSection(
              label: _selectedType == 'To Bank Account' ? 'Account Number' : 'Recipient Username',
              child: TextField(
                controller: _destinationController,
                style: const TextStyle(color: AppColors.textHigh),
                decoration: InputDecoration(
                  hintText: _selectedType == 'To Bank Account' ? 'Enter 10-digit number' : 'Enter @handle',
                ),
              ),
            ),
            const SizedBox(height: 24),

            _InputSection(
              label: 'Amount to Withdraw (BTC)',
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textHigh),
                decoration: InputDecoration(
                  hintText: '0.00',
                  suffixText: 'BTC',
                  suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  errorText: _error,
                ),
                onChanged: (_) => setState(() => _error = null),
              ),
            ),

            const SizedBox(height: 32),

            GlassCard(
              padding: const EdgeInsets.all(20),
              color: AppColors.error.withOpacity(0.03),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Processing Time', 
                    value: _selectedType == 'To Bank Account' ? '1-2 Business Days' : 'Instant',
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(label: 'Network Fee', value: '0.00005 BTC'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.border, thickness: 0.5),
                  ),
                  _SummaryRow(
                    label: 'Total Deduction',
                    value: '${(double.tryParse(_amountController.text) ?? 0 + 0.00005).toStringAsFixed(6)} BTC',
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: _isLoading ? null : _onWithdraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.8),
              ),
              child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                : const Text('Confirm Withdrawal'),
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
            color: isBold ? AppColors.error : AppColors.textHigh,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}

