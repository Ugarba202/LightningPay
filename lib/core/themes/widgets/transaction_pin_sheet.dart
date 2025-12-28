import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../storage/auth_storage.dart';
import '../app_colors.dart';

import '../../../features/auth_wizard/ui/widget/pin_layout.dart';

class TransactionPinSheet extends StatefulWidget {
  final VoidCallback onVerified;

  const TransactionPinSheet({super.key, required this.onVerified});

  static Future<void> show(BuildContext context, {required VoidCallback onVerified}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionPinSheet(onVerified: onVerified),
    );
  }

  @override
  State<TransactionPinSheet> createState() => _TransactionPinSheetState();
}

class _TransactionPinSheetState extends State<TransactionPinSheet> {
  String _pin = '';
  String? _error;
  bool _isValidating = false;

  void _onKeyPressed(String value) async {
    if (_pin.length < 4 && !_isValidating) {
      setState(() {
        _pin += value;
        _error = null;
      });

      if (_pin.length == 4) {
        _validate();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty && !_isValidating) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _validate() async {
    setState(() => _isValidating = true);
    
    // Slight delay for feedback
    await Future.delayed(const Duration(milliseconds: 300));
    
    final savedPin = await AuthStorage.getSavedTransactionPin();
    
    if (savedPin == null) {
      // This shouldn't happen if setup was forced, but handle it
      _handleSuccess();
      return;
    }

    if (_pin == savedPin) {
      _handleSuccess();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _pin = '';
        _error = 'Incorrect PIN';
        _isValidating = false;
      });
    }
  }

  void _handleSuccess() {
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    widget.onVerified();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.bgDark.withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textLow,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: PinLayout(
              title: 'Transaction PIN',
              subtitle: 'Enter your 4-digit PIN to authorize payment',
              pinLength: _pin.length,
              pin: _pin,
              dotCount: 4,
              onKeyPressed: _onKeyPressed,
              onDelete: _onDelete,
              dotColor: AppColors.primary,
            ),
          ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ),
            
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
