// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// Chat Feature Module
///
/// This module handles all chat-related functionality:
/// - Conversations management
/// - Message sending and receiving
/// - Group chat
/// - WebSocket communication
library chat;

// Domain Layer
export 'domain/entities/message_entity.dart';
export 'domain/entities/conversation_entity.dart';
export 'domain/repositories/chat_repository.dart';
export 'domain/usecases/send_message.dart';

// Data Layer
export 'data/datasources/chat_local_datasource.dart';
export 'data/datasources/chat_remote_datasource.dart';

// Presentation Layer - To be migrated from lib/src/chat/
// export 'presentation/providers/chat_message_provider.dart';
// export 'presentation/pages/chat_index_page.dart';
