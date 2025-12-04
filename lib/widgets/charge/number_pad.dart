import 'package:flutter/material.dart';
import 'package:jarpay/constants/colors.dart';

/// A customizable number pad widget for numeric input
///
/// Provides a 3x4 grid of buttons including digits 0-9, double zero (00), and backspace
class NumberPad extends StatelessWidget {
  /// Callback function triggered when a button is pressed
  /// Returns the button value as a String ('0'-'9', '00', or '⌫')
  final Function(String) onNumberPress;

  /// Optional callback for custom backspace handling
  final VoidCallback? onBackspace;

  /// Background color of the buttons
  final Color? buttonColor;

  /// Text color of the buttons
  final Color? textColor;

  /// Button border radius
  final double borderRadius;

  /// Button padding
  final double horizontalPadding;

  const NumberPad({
    super.key,
    required this.onNumberPress,
    this.onBackspace,
    this.buttonColor,
    this.textColor,
    this.borderRadius = 12,
    this.horizontalPadding = 40,
  });

  /// List of button values in the number pad
  static const List<String> _buttons = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0',
    '00',
    '⌫',
  ];

  /// Handles button press events
  void _handleButtonPress(String value) {
    // Special handling for backspace if custom callback is provided
    if (value == '⌫' && onBackspace != null) {
      onBackspace!();
    } else {
      onNumberPress(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _buttons.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 15,
          childAspectRatio: 1.3,
        ),
        itemBuilder: (context, index) {
          final value = _buttons[index];
          return _buildNumberButton(value);
        },
      ),
    );
  }

  /// Builds individual number button
  Widget _buildNumberButton(String value) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor ?? Colors.white.withValues(alpha: 0.2),
        foregroundColor: textColor ?? AppColors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: EdgeInsets.zero,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      onPressed: () => _handleButtonPress(value),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 22,
          color: textColor ?? AppColors.black,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
