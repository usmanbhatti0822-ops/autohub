import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kNotificationsKey = 'notifications_enabled';

/// Persisted locally via shared_preferences — this is a real, functioning
/// toggle (not a decorative switch), it just doesn't talk to a push
/// provider yet since FCM credentials aren't part of this demo.
class NotificationsSettingNotifier extends StateNotifier<bool> {
  NotificationsSettingNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kNotificationsKey) ?? true;
  }

  Future<void> toggle(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotificationsKey, value);
  }
}

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsSettingNotifier, bool>((ref) {
  return NotificationsSettingNotifier();
});
