import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/themes/app_colors.dart';

class EmailStep extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final ValueListenable<bool> showValidationNotifier;

  const EmailStep({
    super.key,
    required this.onCompleted,
    required this.showValidationNotifier,
  });

  @override
  State<EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<EmailStep> {
  String _value = '';
  String? _error;

  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
    widget.showValidationNotifier.addListener(_onShowValidationChanged);
  }

  @override
  void dispose() {
    widget.showValidationNotifier.removeListener(_onShowValidationChanged);
    super.dispose();
  }

  void _onShowValidationChanged() {
    if (widget.showValidationNotifier.value) {
      final isValid = isValidEmail(_value.trim());
      setState(() => _error = isValid ? null : 'Please enter a valid email');
    } else if (_error != null) {
      setState(() => _error = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your email address', style: textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text('Used for account recovery', style: textTheme.bodyMedium),
          const SizedBox(height: 32),
          TextField(
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              errorText: _error,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              _value = value;
              final trimmedValue = _value.trim();
              final valid = isValidEmail(trimmedValue);
              if (valid) {
                widget.onCompleted(trimmedValue);
                if (_error != null) setState(() => _error = null);
              } else {
                widget.onCompleted(''); // Signal invalid state
                if (widget.showValidationNotifier.value) {
                  setState(() => _error = 'Please enter a valid email');
                } else if (_error != null) {
                  setState(() => _error = null);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}