import 'package:flutter/material.dart';

import '../widget/pin_layout.dart';

class PinConfirmStep extends StatefulWidget {
  final String originalPin;
  final VoidCallback onCompleted;
  final Color dotColor;

  const PinConfirmStep({
    super.key,
    required this.originalPin,
    required this.onCompleted,
    this.dotColor = Colors.black,
  });

  @override
  State<PinConfirmStep> createState() => _PinConfirmStepState();
}

class _PinConfirmStepState extends State<PinConfirmStep> {
  String _pin = '';
  String? _error;

  void _onKeyPressed(String value) {
    if (_pin.length < 6) {
      // Keep 6 for consistency, though it will trigger on length == 6
      setState(() {
        _pin += value;
        _error = null; // clear error on new input
      });

      if (_pin.length == 6) {
        if (_pin == widget.originalPin) {
          widget.onCompleted();
        } else {
          // ❌ WRONG PIN
          setState(() {
            _error = 'PINs do not match';
            _pin = '';
          });
        }
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PinLayout(
            title: 'Confirm PIN',
            subtitle: 'Re-enter your PIN to continue',
            pinLength: _pin.length,
            onKeyPressed: _onKeyPressed,
            onDelete: _onDelete,
            dotColor: widget.dotColor,
          ),
        ),

        // 🔴 ERROR MESSAGE
        AnimatedOpacity(
          opacity: _error != null ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: _error != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
