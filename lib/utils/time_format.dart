import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundryan/l10n/app_localizations.dart';

/// Appends a 12-hour time (e.g. "3:45 PM") to [fmt].
/// Doesn't use `add_jm()` because the `id` locale maps it to 24-hour time.
DateFormat with12hTime(DateFormat fmt) => fmt.addPattern('h:mm a');

/// Short date-time for cards: "Today, 3:45 PM", "Tomorrow, 9:00 AM",
/// "12 Oct, 3:45 PM", and the year only when it isn't the current one.
String formatSmartDateTime(
  DateTime date,
  String locale,
  AppLocalizations l10n,
) {
  final now = DateTime.now();
  final time = DateFormat('h:mm a', locale).format(date);
  final dayDiff = DateUtils.dateOnly(date)
      .difference(DateUtils.dateOnly(now))
      .inDays;
  final day = switch (dayDiff) {
    0 => l10n.dayToday,
    1 => l10n.dayTomorrow,
    -1 => l10n.dayYesterday,
    _ when date.year == now.year => DateFormat.MMMd(locale).format(date),
    _ => DateFormat.yMMMd(locale).format(date),
  };
  return '$day, $time';
}

/// Time left until [target] ("in 3 hours"), or null once it has passed.
String? formatTimeUntil(DateTime target, AppLocalizations l10n) {
  final left = target.difference(DateTime.now());
  if (left.isNegative) return null;
  if (left.inMinutes < 60) {
    return l10n.readyInMinutes(left.inMinutes.clamp(1, 59));
  }
  if (left.inHours < 24) return l10n.readyInHours(left.inHours);
  return l10n.readyInDays(left.inDays);
}

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
