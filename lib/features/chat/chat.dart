// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// Chat Feature Module
///
/// This module contains all chat-related functionality including:
/// - Real-time messaging via WebSocket
/// - Group chat management
/// - Message encryption
/// - File transfers
library chat;

// Data Layer
export 'data/api/chat_api.dart';
export 'data/api/chat_message_api.dart';
export 'data/models/chat_message_model.dart';

// Domain Layer
export 'domain/entities/message_entity.dart';
export 'domain/entities/conversation_entity.dart';
export 'domain/usecases/send_message.dart';

// Presentation Layer
export 'presentation/providers/chat_message_provider.dart';
export 'presentation/pages/chat_index_page.dart';
export 'presentation/pages/chat_detail_page.dart';

