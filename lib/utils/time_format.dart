import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Tambahkan jam format 12 jam (mis. "3:45 PM") ke [fmt].
/// Tidak pakai `add_jm()` karena locale `id` memetakannya ke 24 jam.
DateFormat with12hTime(DateFormat fmt) => fmt.addPattern('h:mm a');

/// `showTimePicker` yang selalu tampil dalam mode 12 jam.
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
