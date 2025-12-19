import 'package:flutter/material.dart';

class PinLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final int pinLength;
  final Function(String) onKeyPressed;
  final VoidCallback onDelete;
  final Color dotColor; // color for filled dot
  final int dotCount; // number of dots to show
  final bool showKeyboard; // whether to show on-screen keypad

  const PinLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pinLength,
    required this.onKeyPressed,
    required this.onDelete,
    this.dotColor = Colors.black,
    this.dotCount = 6,
    this.showKeyboard = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    // PIN DOTS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(dotCount, (index) {
                        final filled = index < pinLength;
                        return AnimatedScale(
                          scale: filled ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOut,
                          child: AnimatedOpacity(
                            opacity: filled ? 1.0 : 0.4,
                            duration: const Duration(milliseconds: 150),
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: filled ? dotColor : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 40),
                    // KEYPAD (optional)
                    if (showKeyboard)
                      _PinKeyboard(
                        onKeyPressed: onKeyPressed,
                        onDelete: onDelete,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PinKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onDelete;

  const _PinKeyboard({required this.onKeyPressed, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '⌫'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) {
                return const SizedBox(width: 60);
              }
              return TextButton(
                onPressed: key == '⌫' ? onDelete : () => onKeyPressed(key),
                child: Text(key, style: const TextStyle(fontSize: 22)),
              );
            }).toList(),
          ),
      ],
    );
  }
}
