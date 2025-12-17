import 'package:flutter/material.dart';

class PinCreateStep extends StatefulWidget {
  final ValueChanged<String> onCompleted;

  const PinCreateStep({super.key, required this.onCompleted});

  @override
  State<PinCreateStep> createState() => _PinCreateStepState();
}

class _PinCreateStepState extends State<PinCreateStep> {
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create login PIN',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'This PIN unlocks your app',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              6,
              (index) => Container(
                margin: const EdgeInsets.all(8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _pin.length
                      ? Colors.black
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          _PinKeyboard(onKeyPressed: _onKeyPressed, onDelete: _onDelete),
        ],
      ),
    );
  }
}

class _PinKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onDelete;

  const _PinKeyboard({required this.onKeyPressed, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '⌫'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) {
                return const SizedBox(width: 60);
              }
              return TextButton(
                onPressed: key == '⌫' ? onDelete : () => onKeyPressed(key),
                child: Text(key, style: const TextStyle(fontSize: 22)),
              );
            }).toList(),
          ),
      ],
    );
  }
}
