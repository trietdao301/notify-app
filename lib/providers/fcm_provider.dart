import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final fcmProvider = Provider<FcmService>((ref) => FcmService());

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Replace with your actual HTTP Function URL
  static const String subscribeToTopicUrl =
      'https://subscribetotopic-xea7b3qtqq-uc.a.run.app';
  static const String unsubscribeFromTopicUrl =
      'https://unsubscribefromtopic-xea7b3qtqq-uc.a.run.app';

  Future<void> subscribeToPropertyTopic(String propertyId) async {
    final topic = 'property_$propertyId';
    final String? fcmToken = await _messaging.getToken();
    if (fcmToken == null) {
      throw Exception('FCM token is null');
    }
    try {
      if (!kIsWeb) {
        // For non-web platforms, use client-side subscription
        await _messaging.subscribeToTopic(topic);
        print('Subscribed to FCM topic: $topic');
      } else if (kIsWeb) {
        final response = await _handlePostRequest(
          subscribeToTopicUrl,
          fcmToken,
          topic,
        );
        _handleResponse(response);
      }
    } catch (e) {
      print('Error subscribing to FCM topic: $e');
      rethrow;
    }
  }

  Future<void> unsubscribeFromPropertyTopic(String propertyId) async {
    final topic = 'property_$propertyId';
    final String? fcmToken = await _messaging.getToken();
    if (fcmToken == null) {
      throw Exception('FCM token is null');
    }
    try {
      if (!kIsWeb) {
        await _messaging.unsubscribeFromTopic(topic);
        print('Unsubscribed from FCM topic: $topic');
      } else if (kIsWeb) {
        final response = await _handlePostRequest(
          unsubscribeFromTopicUrl,
          fcmToken,
          topic,
        );
        _handleResponse(response);
      }
    } catch (e) {
      print('Error unsubscribing from FCM topic: $e');
      rethrow;
    }
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('HTTP Function response: $data');
    } else {
      throw Exception(
        'Failed to sub/unsubscribe: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<http.Response> _handlePostRequest(
    String url,
    String fcmToken,
    String topic,
  ) async {
    final body = jsonEncode({'fcmToken': fcmToken, 'topic': topic});
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    return response;
  }
}
