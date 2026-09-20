import '../../../domain/entities/conversation_entity.dart';

enum ConversationFilter {
  all,
  unread,
  groups;

  bool matches(ConversationEntity conversation) => switch (this) {
    all => true,
    unread => conversation.unreadCount > 0,
    groups => conversation.isGroup,
  };
}
