import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

class PinLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final int pinLength;
  final Function(String) onKeyPressed;
  final VoidCallback onDelete;
  final String pin; // actual pin string
  final Color dotColor; // color for filled box border (if used)
  final int dotCount; // number of boxes to show
  final bool showKeyboard; // whether to show on-screen keypad
  final bool useDots; // whether to show dots instead of boxes

  const PinLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pinLength,
    required this.pin,
    required this.onKeyPressed,
    required this.onDelete,
    this.dotColor = AppColors.primary,
    this.dotCount = 6,
    this.showKeyboard = true,
    this.useDots = false,
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
                      style: const TextStyle(
                        color: AppColors.textHigh,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMed,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    // PIN DISPLAY (DOTS or BOXES)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(dotCount, (index) {
                        final filled = index < pinLength;
                        
                        if (useDots) {
                          return AnimatedScale(
                            scale: filled ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOut,
                            child: AnimatedOpacity(
                              opacity: filled ? 1.0 : 0.4,
                              duration: const Duration(milliseconds: 150),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: filled ? dotColor : AppColors.border.withOpacity(0.5),
                                  boxShadow: filled ? [
                                    BoxShadow(
                                      color: dotColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ] : null,
                                ),
                              ),
                            ),
                          );
                        }

                        // BOX STYLE (default)
                        String char = '';
                        if (filled && index < pin.length) {
                          char = pin[index];
                        }
                        
                        return Container(
                          width: 46,
                          height: 52,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              char,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key.isEmpty) {
                  return const SizedBox(width: 80);
                }
                final isDelete = key == '⌫';
                return SizedBox(
                  width: 80,
                  height: 80,
                  child: TextButton(
                    onPressed: isDelete ? onDelete : () => onKeyPressed(key),
                    style: TextButton.styleFrom(
                      shape: const CircleBorder(),
                      foregroundColor: isDelete ? AppColors.error : AppColors.textHigh,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: isDelete ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
