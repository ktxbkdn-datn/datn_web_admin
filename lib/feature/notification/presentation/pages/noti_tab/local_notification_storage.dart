// lib/src/features/notification/data/local_notification_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class LocalNotificationStorage {
  static const String _notificationsKey = 'notifications_with_media';
  static const String _filterTypeKey = 'notificationFilterType';
  static const String _searchQueryKey = 'notificationSearchQuery';

  Future<void> saveNotifications(List<Map<String, dynamic>> notificationsWithMedia) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notificationsKey, jsonEncode(notificationsWithMedia));
    } catch (e) {
      print('Error saving notifications: $e');
      throw Exception('Failed to save notifications: $e');
    }
  }

  Future<List<Map<String, dynamic>>> loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);
      if (notificationsJson != null) {
        final List<dynamic> notificationsList = jsonDecode(notificationsJson);
        return notificationsList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error loading notifications: $e');
      return [];
    }
  }

  Future<void> clearNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  Future<void> saveFilterType(String filterType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_filterTypeKey, filterType);
    } catch (e) {
      print('Error saving filter type: $e');
    }
  }

  Future<String> loadFilterType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_filterTypeKey) ?? 'All';
    } catch (e) {
      print('Error loading filter type: $e');
      return 'All';
    }
  }

  Future<void> saveSearchQuery(String searchQuery) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_searchQueryKey, searchQuery);
    } catch (e) {
      print('Error saving search query: $e');
    }
  }

  Future<String> loadSearchQuery() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_searchQueryKey) ?? '';
    } catch (e) {
      print('Error loading search query: $e');
      return '';
    }
  }
}