import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../core/utils/debug_log.dart';
import '../../domain/entities/story_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../../n42_chat.dart';
import '../blocs/story/story_bloc.dart';
import '../blocs/story/story_event.dart';
import '../blocs/story/story_state.dart';

class StoryInteractionHelper {
  const StoryInteractionHelper._();

  static Future<bool> replyToStory(
    BuildContext context, {
    required String userId,
    required String storyId,
    required String message,
  }) async {
    debugLog('Reply to story $storyId from user $userId: $message');
    try {
      final roomId = await N42Chat.createDirectMessage(userId);
      final trimmedMessage = message.trim();
      if (trimmedMessage.isNotEmpty) {
        await getIt<IMessageRepository>().sendTextMessage(
          roomId,
          trimmedMessage,
        );
      }
      if (!context.mounted) return false;
      await N42Chat.openConversation(roomId, context: context);
      return true;
    } catch (e) {
      debugLog('StoryInteractionHelper: Failed to create story reply DM: $e');
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send story reply')),
      );
      return false;
    }
  }

  static Future<bool> deleteStory({
    required StoryBloc storyBloc,
    required StoryEntity story,
  }) async {
    final initialVersion = storyBloc.state.deleteActionVersion;
    final completer = Completer<bool>();
    late final StreamSubscription<StoryState> subscription;

    subscription = storyBloc.stream.listen((state) {
      if (state.deleteActionVersion == initialVersion) {
        return;
      }
      if (state.deleteActionStoryId != story.id) {
        return;
      }
      if (completer.isCompleted) {
        return;
      }
      completer.complete(
        state.deleteActionStatus == StoryDeleteActionStatus.success,
      );
    });

    storyBloc.add(DeleteStory(story.id));

    try {
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => false,
      );
    } finally {
      await subscription.cancel();
    }
  }
}
