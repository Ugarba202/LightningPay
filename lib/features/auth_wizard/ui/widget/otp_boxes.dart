import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/themes/app_colors.dart';

class OtpBoxes extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final String? initialValue;

  /// Color used for active/filled box border/text
  final Color activeColor;

  const OtpBoxes({
    super.key,
    required this.onCompleted,
    this.length = 6,
    this.initialValue,
    this.activeColor = AppColors.primary,
  });

  @override
  State<OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<OtpBoxes> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      final digits = widget.initialValue!.replaceAll(RegExp(r'[^0-9]'), '');
      for (var i = 0; i < widget.length && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _updateFromPaste(String pasted, int startIndex) {
    final digits = pasted.replaceAll(RegExp(r'[^0-9]'), '');
    var idx = startIndex;
    for (var i = 0; i < digits.length && idx < widget.length; i++, idx++) {
      _controllers[idx].text = digits[i];
    }
    _moveFocusToNextEmpty();
    _notifyIfCompleted();
  }

  void _moveFocusToNextEmpty() {
    for (var i = 0; i < widget.length; i++) {
      if (_controllers[i].text.isEmpty) {
        _focusNodes[i].requestFocus();
        return;
      }
    }
    // none empty — focus last
    _focusNodes.last.requestFocus();
  }

  void _notifyIfCompleted() {
    final allFilled = _controllers.every(
      (c) => c.text.length == 1 && RegExp(r'^\d$').hasMatch(c.text),
    );
    if (allFilled) widget.onCompleted(_controllers.map((c) => c.text).join());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Container(
          width: 46,
          height: 52, // Reduced height
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary, // Changed to orange
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
              onChanged: (value) {
                if (value.length > 1) {
                  _updateFromPaste(value, index);
                  return;
                }

                if (value.isNotEmpty) {
                  if (index + 1 < widget.length) {
                    _focusNodes[index + 1].requestFocus();
                  } else {
                    _focusNodes[index].unfocus();
                  }
                } else {
                  if (index - 1 >= 0) {
                    _focusNodes[index - 1].requestFocus();
                    _controllers[index - 1].selection = TextSelection.collapsed(
                      offset: _controllers[index - 1].text.length,
                    );
                  }
                }

                _notifyIfCompleted();
              },
            ),
          ),
        );
      }),
    );
  }
}
