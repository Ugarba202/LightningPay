import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  final String label;
  final String initialValue;

  const ProfileTextField({
    super.key,
    required this.label,
    required this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }
}
