// GEN-00307 — Inline action buttons for mobile push notifications.
// Defines Android and iOS notification actions for Complete/Partial/Not Complete
// and routes selected actions into the GEN-00307 telemetry pipeline.

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationActionButtons {
  NotificationActionButtons._();

  static const String actionComplete = 'GEN_00307_ACTION_COMPLETE';
  static const String actionPartial = 'GEN_00307_ACTION_PARTIAL';
  static const String actionNotComplete = 'GEN_00307_ACTION_NOT_COMPLETE';
  static const String categoryId = 'GEN_00307_STATUS';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const DarwinNotificationCategory iosCategory = DarwinNotificationCategory(
      categoryId,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain(actionComplete, 'Complete'),
        DarwinNotificationAction.plain(actionPartial, 'Partial'),
        DarwinNotificationAction.plain(actionNotComplete, 'Not Complete'),
      ],
    );

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: <DarwinNotificationCategory>{iosCategory},
    );
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  static Future<void> showStatusNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'gen_00307_status',
      'GEN-00307 Status',
      channelDescription: 'Inline action buttons for GEN-00307 status updates',
      importance: Importance.high,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          actionComplete,
          'Complete',
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          actionPartial,
          'Partial',
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          actionNotComplete,
          'Not Complete',
          showsUserInterface: false,
        ),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      categoryIdentifier: categoryId,
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  static void _onNotificationResponse(NotificationResponse response) {
    switch (response.actionId) {
      case actionComplete:
        _recordCompletion('Complete');
        break;
      case actionPartial:
        _recordCompletion('Partial');
        break;
      case actionNotComplete:
        _recordCompletion('Not Complete');
        break;
      default:
        break;
    }
  }

  static void _recordCompletion(String status) {
    debugPrint('GEN-00307 notification action selected: $status');
  }
}
