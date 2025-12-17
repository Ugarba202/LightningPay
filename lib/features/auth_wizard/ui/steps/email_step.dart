import 'package:flutter/material.dart';

class EmailStep extends StatelessWidget {
  final ValueChanged<String> onCompleted;

  const EmailStep({super.key, required this.onCompleted});
  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your email address',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Used for account recovery',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          TextField(
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Enter your email'),
            onChanged: (value) {
              if (value.contains('@')) {
                onCompleted(value.trim());
              }
            },
          ),
        ],
      ),
    );
  }
}
