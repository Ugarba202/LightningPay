import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/themes/app_colors.dart';

class UsernameStep extends StatefulWidget {
  final ValueChanged<String> onValidationChanged;
  final ValueListenable<bool> showValidationNotifier;

  const UsernameStep({
    super.key,
    required this.onValidationChanged,
    required this.showValidationNotifier,
  });

  @override
  State<UsernameStep> createState() => _UsernameStepState();
}

class _UsernameStepState extends State<UsernameStep> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    // Add a listener to the controller to validate on each change.
    _controller.addListener(() => _validateUsername(_controller.text));
    widget.showValidationNotifier.addListener(_onShowValidationChanged);
  }

  @override
  void dispose() {
    widget.showValidationNotifier.removeListener(_onShowValidationChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onShowValidationChanged() {
    // Re-run validation when parent requests showing errors
    if (widget.showValidationNotifier.value) {
      _validateUsername(_controller.text);
    } else if (_error != null) {
      setState(() => _error = null);
    }
  }

  void _validateUsername(String value) {
    final trimmedValue = value.trim();
    final hasSpace = RegExp(r'\s').hasMatch(trimmedValue);
    final isValid = trimmedValue.length >= 3 && !hasSpace;

    if (isValid) {
      if (_error != null) setState(() => _error = null);
      widget.onValidationChanged(trimmedValue);
    } else {
      widget.onValidationChanged('');
      if (widget.showValidationNotifier.value) {
        setState(() {
          if (trimmedValue.length < 3) {
            _error = 'Username must be at least 3 characters';
          } else if (hasSpace) {
            _error = 'Username cannot contain spaces';
          } else {
            _error = 'Invalid username';
          }
        });
      } else if (_error != null) {
        setState(() => _error = null);
      }
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
            'Create a username',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          TextField(
            autofocus: true,
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Username',
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
          ),
        ],
      ),
    );
  }
}
