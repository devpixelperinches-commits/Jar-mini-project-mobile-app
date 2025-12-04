import 'package:flutter/material.dart';

enum MessageType { success, error, warning }

class TopMessageHelper {
  static void showTopMessage(
    BuildContext context,
    String message, {
    MessageType type = MessageType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);

    // Background color based on message type
    Color bgColor;
    Color textColor = Colors.white;
    IconData icon;

    switch (type) {
      case MessageType.success:
        bgColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case MessageType.error:
        bgColor = Colors.redAccent;
        icon = Icons.error;
        break;
      case MessageType.warning:
        bgColor = Colors.amber;
        textColor = Colors.black;
        icon = Icons.warning_amber_rounded;
        break;
    }

    // Create overlay entry
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset: const Offset(0, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, color: textColor, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Insert overlay entry
    overlay.insert(overlayEntry);

    // Auto remove after delay
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}
