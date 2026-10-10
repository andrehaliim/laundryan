import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Appends a 12-hour time (e.g. "3:45 PM") to [fmt].
/// Doesn't use `add_jm()` because the `id` locale maps it to 24-hour time.
DateFormat with12hTime(DateFormat fmt) => fmt.addPattern('h:mm a');

/// `showTimePicker` that always displays in 12-hour mode.
Future<TimeOfDay?> showTimePicker12h({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (ctx, child) => MediaQuery(
      data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
      child: child!,
    ),
  );
}
