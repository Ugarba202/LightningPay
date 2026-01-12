import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/service/user_service.dart';
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
  final _userService = UserService();
  String? _error;
  bool _isChecking = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    widget.showValidationNotifier.addListener(_onShowValidationChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.showValidationNotifier.removeListener(_onShowValidationChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _validateUsername(_controller.text);
  }

  void _onShowValidationChanged() {
    if (widget.showValidationNotifier.value) {
      _validateUsername(_controller.text);
    } else if (_error != null) {
      setState(() => _error = null);
    }
  }

  Future<void> _validateUsername(String value) async {
    final trimmedValue = value.trim();
    final hasSpace = RegExp(r'\s').hasMatch(trimmedValue);
    final isBasicValid = trimmedValue.length >= 3 && !hasSpace;

    _debounceTimer?.cancel();

    if (!isBasicValid) {
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
      return;
    }

    // Basic validation passed, now check availability with debounce
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isChecking = true);
      
      final isAvailable = await _userService.isUsernameAvailable(trimmedValue);
      
      if (!mounted) return;

      setState(() {
        _isChecking = false;
        if (isAvailable) {
          _error = null;
          widget.onValidationChanged(trimmedValue);
        } else {
          _error = 'Username is already taken';
          widget.onValidationChanged('');
        }
      });
    });
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
              suffixIcon: _isChecking
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
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
