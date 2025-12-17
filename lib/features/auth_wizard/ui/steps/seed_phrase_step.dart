import 'package:flutter/material.dart';

class SeedPhraseStep extends StatefulWidget {
  final VoidCallback onCompleted;

  const SeedPhraseStep({super.key, required this.onCompleted});

  @override
  State<SeedPhraseStep> createState() => _SeedPhraseStepState();
}

class _SeedPhraseStepState extends State<SeedPhraseStep> {
  bool _confirmed = false;

  final List<String> _seedWords = const [
    'light',
    'river',
    'coffee',
    'tree',
    'wallet',
    'secure',
    'orange',
    'planet',
    'trust',
    'future',
    'energy',
    'freedom',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your recovery phrase',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Write these words down. Anyone with them can access your wallet.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _seedWords
                .asMap()
                .entries
                .map(
                  (entry) =>
                      Chip(label: Text('${entry.key + 1}. ${entry.value}')),
                )
                .toList(),
          ),

          const SizedBox(height: 24),

          CheckboxListTile(
            value: _confirmed,
            onChanged: (value) => setState(() => _confirmed = value ?? false),
            title: const Text('I have safely saved my recovery phrase'),
          ),

          const Spacer(),

          ElevatedButton(
            onPressed: _confirmed ? widget.onCompleted : null,
            child: const Text('Finish setup'),
          ),
        ],
      ),
    );
  }
}
