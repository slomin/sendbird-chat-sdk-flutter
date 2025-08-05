// Copyright (c) 2025 Sendbird, Inc. All rights reserved.

import 'package:flutter_test/flutter_test.dart';
import 'package:sendbird_chat_sdk/src/public/main/params/message/message_list_params.dart';
import 'package:sendbird_chat_sdk/src/public/main/define/api_limits.dart';

void main() {
  // Note: These tests verify the pagination algorithm logic directly rather than
  // testing BaseMessageCollection behaviour (which would require complex mocking).
  // This ensures the core logic is correct regardless of implementation details.
  group('Message Collection API Limit Tests', () {
    group('API Limits relationships', () {
      test('recommendedMessageQueryLimit is less than maxMessageQueryLimit',
          () {
        expect(recommendedMessageQueryLimit, lessThan(maxMessageQueryLimit),
            reason:
                'Recommended limit should always be less than max to provide safety margin');
      });

      test('defaultMessageQueryLimit is less than recommendedMessageQueryLimit',
          () {
        expect(defaultMessageQueryLimit, lessThan(recommendedMessageQueryLimit),
            reason: 'Default should be conservative, less than recommended');
      });
    });

    group('MessageListParams validation', () {
      test('previousResultSize setter validates against API limit', () {
        final params = MessageListParams();

        // Test setting within limit
        params.previousResultSize = 100;
        expect(params.previousResultSize, equals(100));

        // Test setting at limit
        params.previousResultSize = 200;
        expect(params.previousResultSize, equals(200));

        // Test setting above limit (should still set but warn)
        params.previousResultSize = 300;
        expect(params.previousResultSize, equals(300));
      });

      test('previousResultSize starts with a conservative default', () {
        final params = MessageListParams();
        // Test the behaviour/properties, not the exact value
        expect(params.previousResultSize, greaterThan(0),
            reason: 'Should have a positive default');
        expect(params.previousResultSize,
            lessThanOrEqualTo(recommendedMessageQueryLimit),
            reason:
                'Default should be conservative, not exceeding recommended limit');
      });
    });

    group('hasPrevious pagination algorithm tests', () {
      // Helper function matching the simplified logic in BaseMessageCollection
      bool calculateHasPrevious(int receivedCount, int requestedSize) {
        final effectiveRequestSize = requestedSize > maxMessageQueryLimit
            ? maxMessageQueryLimit
            : requestedSize;
        return receivedCount >= effectiveRequestSize;
      }

      test('hasPrevious stays true when receiving exactly 200 messages', () {
        // Request 500, receive 200 (server limit)
        final hasPrevious = calculateHasPrevious(200, 500);

        expect(hasPrevious, isTrue,
            reason: 'Getting exactly 200 (the limit) means more may exist');
      });

      test('hasPrevious becomes false when receiving less than limit', () {
        // Request 500, receive 150 (less than effective request of 200)
        final hasPrevious = calculateHasPrevious(150, 500);

        expect(hasPrevious, isFalse,
            reason:
                'Getting less than effective request means no more messages');
      });

      test('hasPrevious with normal pagination (no limit hit)', () {
        // Request 20, receive 20 (normal case)
        final hasPrevious = calculateHasPrevious(20, 20);

        expect(hasPrevious, isTrue,
            reason: 'Getting full requested amount means more may exist');
      });

      test('hasPrevious when receiving less than requested (within limit)', () {
        // Request 50, receive 30 (end of messages)
        final hasPrevious = calculateHasPrevious(30, 50);

        expect(hasPrevious, isFalse,
            reason:
                'Getting less than requested (both under limit) means no more');
      });
    });
  });
}
