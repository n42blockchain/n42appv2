// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:n42_wallet/core/error/failures.dart';
import 'package:n42_wallet/core/usecase/usecase.dart';
import 'package:n42_wallet/features/chat/domain/entities/message_entity.dart';
import 'package:n42_wallet/features/chat/domain/repositories/chat_repository.dart';

/// Send Message Use Case
@injectable
class SendMessage implements UseCase<MessageEntity, SendMessageParams> {
  final ChatRepository _repository;

  SendMessage(this._repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) async {
    // Validate content
    if (params.content.isEmpty && params.type == MessageType.text) {
      return const Left(ValidationFailure(message: 'Message content cannot be empty'));
    }

    return await _repository.sendMessage(
      conversationId: params.conversationId,
      content: params.content,
      type: params.type,
      replyToId: params.replyToId,
      extra: params.extra,
    );
  }
}

/// Parameters for SendMessage use case
class SendMessageParams extends Equatable {
  final String conversationId;
  final String content;
  final MessageType type;
  final String? replyToId;
  final Map<String, dynamic>? extra;

  const SendMessageParams({
    required this.conversationId,
    required this.content,
    this.type = MessageType.text,
    this.replyToId,
    this.extra,
  });

  @override
  List<Object?> get props => [conversationId, content, type, replyToId, extra];
}

/// Get Messages Use Case
@injectable
class GetMessages implements UseCase<List<MessageEntity>, GetMessagesParams> {
  final ChatRepository _repository;

  GetMessages(this._repository);

  @override
  Future<Either<Failure, List<MessageEntity>>> call(GetMessagesParams params) async {
    return await _repository.getMessages(
      conversationId: params.conversationId,
      page: params.page,
      limit: params.limit,
    );
  }
}

/// Parameters for GetMessages use case
class GetMessagesParams extends Equatable {
  final String conversationId;
  final int page;
  final int limit;

  const GetMessagesParams({
    required this.conversationId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [conversationId, page, limit];
}

/// Mark Messages Read Use Case
@injectable
class MarkMessagesRead implements UseCase<void, MarkMessagesReadParams> {
  final ChatRepository _repository;

  MarkMessagesRead(this._repository);

  @override
  Future<Either<Failure, void>> call(MarkMessagesReadParams params) async {
    return await _repository.markAsRead(
      conversationId: params.conversationId,
      untilMessageId: params.untilMessageId,
    );
  }
}

/// Parameters for MarkMessagesRead use case
class MarkMessagesReadParams extends Equatable {
  final String conversationId;
  final String? untilMessageId;

  const MarkMessagesReadParams({
    required this.conversationId,
    this.untilMessageId,
  });

  @override
  List<Object?> get props => [conversationId, untilMessageId];
}

