// Copyright (c) 2025 Sendbird, Inc. All rights reserved.

/// Maximum number of messages that can be retrieved in a single API call.
/// This is a hard limit enforced by the Sendbird backend.
const int maxMessageQueryLimit = 200;

/// Default query limit for messages when not specified.
/// Used as the initial value for MessageListParams.previousResultSize.
const int defaultMessageQueryLimit = 20;

/// Recommended maximum for stable operation and optimal performance.
/// Used for auto-chunking large requests and as guidance in warnings.
const int recommendedMessageQueryLimit = 100;
