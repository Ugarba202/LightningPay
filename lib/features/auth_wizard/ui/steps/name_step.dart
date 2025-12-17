import 'package:flutter/material.dart';

class NameStep extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  const NameStep({super.key, required this.onCompleted});

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What should we call you?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Full name',
              errorText: _error,
            ),
            onChanged: (value) {
              if (value.trim().length >= 2) {
                widget.onCompleted(value.trim());
              } else {
                setState(() {
                  _error = 'Please enter your full name';
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
