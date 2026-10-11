import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channel = MethodChannel('laundryan/notifications');
  static AppLifecycleListener? _lifecycle;

  /// Whether the OS currently allows this app to show notifications.
  /// Refreshed on startup, after a permission request and on app resume.
  static final enabled = ValueNotifier<bool>(true);

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_laundryan'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
    } catch (_) {}

    await refreshEnabled();
    _lifecycle ??= AppLifecycleListener(onResume: refreshEnabled);
  }

  static Future<void> refreshEnabled() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        enabled.value = await android.areNotificationsEnabled() ?? true;
        return;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        enabled.value = (await ios.checkPermissions())?.isEnabled ?? true;
      }
    } catch (_) {}
  }

  /// Opens the system notification settings for this app.
  static Future<void> openSettings() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod<void>('openSettings');
      } else {
        await launchUrl(Uri.parse('app-settings:'));
      }
    } catch (_) {}
  }

  /// true if permission is granted.
  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission() ?? false;
      enabled.value = granted;
      return granted;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted =
          await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      enabled.value = granted;
      return granted;
    }
    return false;
  }

  /// Skipped if the time has already passed or permission is denied.
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime fireAt,
  }) async {
    if (!fireAt.isAfter(DateTime.now())) return;
    try {
      if (!await requestPermission()) return;
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(fireAt, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'session_reminder',
            'Session reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {}
  }

  static Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id: id);
    } catch (_) {}
  }
}

/// Tells the user a reminder won't show because notifications are blocked,
/// with a shortcut to the system settings.
void showNotificationsBlocked(
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
) {
  messenger.showSnackBar(
    SnackBar(
      content: Text(l10n.notificationsBlocked),
      action: SnackBarAction(
        label: l10n.settings,
        onPressed: NotificationService.openSettings,
      ),
    ),
  );
}
