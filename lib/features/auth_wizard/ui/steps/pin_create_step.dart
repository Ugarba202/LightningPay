import 'package:flutter/material.dart';

import '../widget/pin_layout.dart';

class PinCreateStep extends StatefulWidget {
  final ValueChanged<String> onCompleted;

  const PinCreateStep({super.key, required this.onCompleted});

  @override
  State<PinCreateStep> createState() => _PinCreateStepState();
}

class _PinCreateStepState extends State<PinCreateStep> {
  String _pin = '';

  void _onKeyPressed(String value) {
    if (_pin.length < 6) {
      setState(() => _pin += value);
      if (_pin.length == 6) {
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
      title: 'Create login PIN',
      subtitle: 'This 6-digit PIN unlocks your app',
      pinLength: _pin.length,
      pin: _pin,
      onKeyPressed: _onKeyPressed,
      onDelete: _onDelete,
      dotColor: Colors.orange, 
      useDots: true,
    );
  }
}
