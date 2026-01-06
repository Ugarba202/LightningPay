import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/widgets/glass_card.dart';
import '../logic/withdraw_logic.dart';
import '../../convert/ui/convert_screen.dart';
import '../../../../core/service/wallet_stream_service.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/constant/contry_code.dart';



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
  String _localCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadUserCountry();
  }

  Future<void> _loadUserCountry() async {
    final countryName = await AuthStorage.getCountry();
    if (countryName != null) {
      final country = Country.getByName(countryName);
      if (country != null) {
        setState(() {
          _localCurrency = country.currencyCode;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _onWithdraw() {
    setState(() => _error = null);

    if (!_logic.validateAmount(_amountController.text)) {
      setState(() => _error = "Please enter a valid amount");
      return;
    }

    final balanceError = _logic.checkBalance(_amountController.text);
    setState(() async => _error = await balanceError);
    return;
  
  }

  void executeWithdraw() async {
    setState(() => _isLoading = true);

    try {
      await _logic.processWithdraw(
        amount: _amountController.text,
        type: _selectedType,
        destination: _destinationController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Withdraw Successful! Balance Updated.')),
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
            // Balance Info & Redirect
            StreamBuilder<Map<String, dynamic>>(
              stream: WalletStreamService().walletStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                final wallet = snapshot.data!;
                final localBalance = (wallet['localBalance'] ?? 0.0).toDouble();
                final btcBalance = (wallet['btcBalance'] ?? 0.0).toDouble();

                if (localBalance <= 0 && btcBalance > 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.primary.withOpacity(0.1),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Only local currency can be withdrawn.',
                                  style: TextStyle(color: AppColors.textHigh, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ConvertScreen()),
                                  ),
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                  child: Text('Convert BTC to $_localCurrency first', style: const TextStyle(color: AppColors.primary)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

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
              label: _selectedType == 'To Bank Account' ? 'Bank Account Number' : 'Recipient Username',
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
              label: 'Amount to Withdraw',
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textHigh),
                decoration: InputDecoration(
                  hintText: '0.00',
                  suffixText: _localCurrency,
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
                  _SummaryRow(label: 'Network Fee', value: '1.50 $_localCurrency'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.border, thickness: 0.5),
                  ),
                  _SummaryRow(
                    label: 'Amount to Receive',
                    value: '${_localCurrency == 'USD' ? '\$' : ''}${(double.tryParse(_amountController.text) ?? 0).toStringAsFixed(2)} $_localCurrency',
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

