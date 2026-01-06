import 'package:flutter/material.dart';
import '../../../../core/constant/contry_code.dart';


class PhoneStep extends StatefulWidget {
  final Country country;
  final String? initialValue;
  final ValueChanged<String> onCompleted;

  const PhoneStep({
    super.key,
    required this.country,
    this.initialValue,
    required this.onCompleted,
  });

  @override
  State<PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends State<PhoneStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your phone number',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'We’ll use this to secure your account',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.country.flag} ${widget.country.dialCode}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  autofocus: true,
                  controller: _controller,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Phone number',
                  ),
                  onChanged: (value) {
                    if (value.length >= 7) {
                      widget.onCompleted(value);
                    } else {
                      widget.onCompleted('');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
