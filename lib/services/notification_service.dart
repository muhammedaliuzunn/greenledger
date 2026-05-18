import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _greenChannel = AndroidNotificationDetails(
    'greenscore_channel',
    'GreenScore Bildirimleri',
    channelDescription: 'GreenScore başarı ve uyarıları',
    importance: Importance.high,
    priority: Priority.high,
    color: Color(0xFF16A34A),
    icon: '@mipmap/ic_launcher',
  );

  static const _creditChannel = AndroidNotificationDetails(
    'credit_channel',
    'Kredi Bildirimleri',
    channelDescription: 'Kredi başvuru durum bildirimleri',
    importance: Importance.high,
    priority: Priority.high,
    color: Color(0xFF0EA5E9),
    icon: '@mipmap/ic_launcher',
  );

  static const _ecoChannel = AndroidNotificationDetails(
    'eco_channel',
    'Eko Başarılar',
    channelDescription: 'Çevre dostu başarı bildirimleri',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    color: Color(0xFF16A34A),
    icon: '@mipmap/ic_launcher',
  );

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  static Future<void> showGreenScoreAlert(String sellerName, int score) async {
    await _plugin.show(
      0,
      'GreenScore Basarisi!',
      '$sellerName mukemmel skora ulasti: $score/100',
      const NotificationDetails(android: _greenChannel),
    );
  }

  static Future<void> showCreditApproved(String sellerName, double amount) async {
    await _plugin.show(
      1,
      'Kredi Onaylandi!',
      '$sellerName icin ${(amount / 1000).toStringAsFixed(0)}K TL kredi onaylandi',
      const NotificationDetails(android: _creditChannel),
    );
  }

  static Future<void> showCreditDisbursed(String sellerName, double amount) async {
    await _plugin.show(
      2,
      'Kredi Odendi!',
      '$sellerName hesabina ${(amount / 1000).toStringAsFixed(0)}K TL aktarildi',
      const NotificationDetails(android: _creditChannel),
    );
  }

  static Future<void> showEcoAchievement(String message) async {
    await _plugin.show(
      3,
      'Eko Basari!',
      message,
      const NotificationDetails(android: _ecoChannel),
    );
  }

  static Future<void> showTestNotification() async {
    await _plugin.show(
      99,
      'GreenLedger Bildirimi',
      'Bildirimler basariyla calisyor! Yesil finansin gelecegi burada.',
      const NotificationDetails(android: _greenChannel),
    );
  }
}
