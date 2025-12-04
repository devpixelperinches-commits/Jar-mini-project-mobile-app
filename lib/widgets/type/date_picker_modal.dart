import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerModal {
  static Future<DateTime?> show(BuildContext context, DateTime? initialDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C22A6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  static String format(DateTime? date) {
    return date == null ? '' : DateFormat('d MMM yyyy').format(date);
  }
}
