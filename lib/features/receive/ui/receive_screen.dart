import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:breez_sdk/bridge_generated.dart';

import '../../../core/service/breeze_service.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/widgets/glass_card.dart';

enum ReceiveType { lightning, onchain }

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  ReceiveType _type = ReceiveType.lightning;
  String? _qrData;
  bool _isLoading = false;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
    if (_type == ReceiveType.onchain) {
      _generateOnchain();
    }
  }

  Future<void> _generateInvoice() async {
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await BreezeService.instance.receivePayment(
        amountSats: amount,
        description: 'LightningPay Deposit',
      );
      setState(() {
        _qrData = response.lnInvoice.bolt11;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _generateOnchain() async {
    setState(() => _isLoading = true);
    try {
      final response = await BreezeService.instance.receiveOnchain();
      setState(() {
        _qrData = response.address;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive Bitcoin'), elevation: 0),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'Lightning',
                      isSelected: _type == ReceiveType.lightning,
                      onTap: () {
                        setState(() {
                          _type = ReceiveType.lightning;
                          _qrData = null;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _TypeButton(
                      label: 'On-chain',
                      isSelected: _type == ReceiveType.onchain,
                      onTap: () {
                        setState(() {
                          _type = ReceiveType.onchain;
                          _qrData = null;
                        });
                        _generateOnchain();
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (_type == ReceiveType.lightning && _qrData == null)
              _AmountInput(
                controller: _amountController,
                onGenerate: _generateInvoice,
                isLoading: _isLoading,
              )
            else if (_isLoading)
              const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_qrData != null)
              Column(
                children: [
                  _QrContainer(qrData: _qrData!),
                  const SizedBox(height: 32),
                  _AddressCard(address: _qrData!),
                  const SizedBox(height: 32),
                  _ActionButtons(data: _qrData!),
                ],
              ),

            const SizedBox(height: 48),

            // Security Note
            GlassCard(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withOpacity(0.03),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _type == ReceiveType.lightning
                          ? 'This invoice is for Lightning payments only. It will expire after a certain period.'
                          : 'Only send Bitcoin (BTC) to this address. Sending any other currency may result in permanent loss.',
                      style: const TextStyle(
                        color: AppColors.textMed,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMed,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onGenerate;
  final bool isLoading;

  const _AmountInput({
    required this.controller,
    required this.onGenerate,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            hintText: '0',
            suffixText: 'sats',
            border: InputBorder.none,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: isLoading ? null : onGenerate,
          child: const Text('Create Invoice'),
        ),
      ],
    );
  }
}

class _QrContainer extends StatelessWidget {
  final String qrData;
  const _QrContainer({required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: QrImageView(data: qrData, size: 200),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String address;
  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: SelectableText(
        address,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: AppColors.textHigh),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final String data;
  const _ActionButtons({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: data));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
        ),
      ],
    );
  }
}
