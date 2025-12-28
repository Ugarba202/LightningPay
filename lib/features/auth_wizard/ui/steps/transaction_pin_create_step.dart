import 'package:flutter/material.dart';
import '../widget/pin_layout.dart';

class TransactionPinCreateStep extends StatefulWidget {
  final ValueChanged<String> onCompleted;

  const TransactionPinCreateStep({super.key, required this.onCompleted});

  @override
  State<TransactionPinCreateStep> createState() =>
      _TransactionPinCreateStepState();
}

class _TransactionPinCreateStepState extends State<TransactionPinCreateStep> {
  String _pin = '';

  void _onKeyPressed(String value) {
    if (_pin.length < 4) {
      setState(() => _pin += value);
      if (_pin.length == 4) {
        widget.onCompleted(_pin);
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PinLayout(
      title: 'Create transaction PIN',
      subtitle: 'This protects your payments',
      pinLength: _pin.length,
      onKeyPressed: _onKeyPressed,
      onDelete: _onDelete, pin: '',
    );
  }
}
