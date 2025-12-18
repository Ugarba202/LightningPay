import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/themes/app_colors.dart';

class NameStep extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final ValueListenable<bool> showValidationNotifier;

  const NameStep({
    super.key,
    required this.onCompleted,
    required this.showValidationNotifier,
  });

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  String _value = '';
  String? _error;

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
    // When parent requests showing validation, re-run validation for current value
    if (widget.showValidationNotifier.value) {
      final isValid = _value.trim().length >= 2;
      setState(() {
        _error = isValid ? null : 'Enter your complete name';
      });
    } else {
      setState(() => _error = null);
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
            'What should we call you?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Full name',
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
              final isValid = _value.trim().length >= 2;
              if (isValid) {
                widget.onCompleted(_value.trim());
              } else {
                widget.onCompleted('');
                // Only show the error if parent flagged validation
                if (widget.showValidationNotifier.value) {
                  setState(() {
                    _error = 'Enter your complete name';
                  });
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
