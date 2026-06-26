import 'package:equatable/equatable.dart';

class ChatMentionMember extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;

  const ChatMentionMember({
    required this.id,
    required this.name,
    this.avatarUrl = '',
  });

  @override
  List<Object?> get props => [id, name, avatarUrl];
}

enum ChatMentionSuggestionType { user, room }

class ChatMentionSuggestion extends Equatable {
  final ChatMentionSuggestionType type;
  final String label;
  final String displayName;
  final String? userId;
  final String avatarUrl;
  final String? subtitle;

  const ChatMentionSuggestion({
    required this.type,
    required this.label,
    required this.displayName,
    this.userId,
    this.avatarUrl = '',
    this.subtitle,
  });

  bool get mentionsRoom => type == ChatMentionSuggestionType.room;
  String get mentionText => '@$label';
  String get insertionText => '$mentionText ';
  String get key => userId ?? 'room:$label';

  @override
  List<Object?> get props => [type, label, displayName, userId, avatarUrl];
}

class ChatMentionSelection extends Equatable {
  final String label;
  final String? userId;
  final bool mentionsRoom;

  const ChatMentionSelection({
    required this.label,
    this.userId,
    this.mentionsRoom = false,
  });

  factory ChatMentionSelection.fromSuggestion(
    ChatMentionSuggestion suggestion,
  ) {
    return ChatMentionSelection(
      label: suggestion.label,
      userId: suggestion.userId,
      mentionsRoom: suggestion.mentionsRoom,
    );
  }

  String get mentionText => '@$label';
  String get key => userId ?? 'room:$label';

  @override
  List<Object?> get props => [label, userId, mentionsRoom];
}

class ChatMentionTrigger extends Equatable {
  final int triggerPosition;
  final String query;

  const ChatMentionTrigger({
    required this.triggerPosition,
    required this.query,
  });

  @override
  List<Object?> get props => [triggerPosition, query];
}

class ChatMentionInsertionResult extends Equatable {
  final String text;
  final int cursorOffset;
  final ChatMentionSelection selection;

  const ChatMentionInsertionResult({
    required this.text,
    required this.cursorOffset,
    required this.selection,
  });

  @override
  List<Object?> get props => [text, cursorOffset, selection];
}

class ChatMentionPayload extends Equatable {
  final List<String> mentionedUserIds;
  final bool mentionsRoom;

  const ChatMentionPayload({
    this.mentionedUserIds = const [],
    this.mentionsRoom = false,
  });

  bool get isEmpty => mentionedUserIds.isEmpty && !mentionsRoom;

  @override
  List<Object?> get props => [mentionedUserIds, mentionsRoom];
}

class ChatMentionHelper {
  static const Set<String> _triggerBoundaryChars = {
    ' ',
    '\n',
    '\t',
    ',',
    '，',
    '.',
    '。',
    '!',
    '！',
    '?',
    '？',
    ':',
    '：',
    ';',
    '；',
    '、',
    '(',
    '（',
    '[',
    '【',
    '{',
    '｛',
    '<',
    '《',
    '「',
    '『',
  };
  static final Set<String> _roomAliases = _roomSuggestions
      .map((suggestion) => suggestion.label.toLowerCase())
      .toSet();
  static const List<ChatMentionSuggestion> _roomSuggestions = [
    ChatMentionSuggestion(
      type: ChatMentionSuggestionType.room,
      label: 'all',
      displayName: 'All Members',
      subtitle: 'Notify everyone in this chat',
    ),
    ChatMentionSuggestion(
      type: ChatMentionSuggestionType.room,
      label: 'everyone',
      displayName: 'Everyone',
      subtitle: 'Notify everyone in this chat',
    ),
    ChatMentionSuggestion(
      type: ChatMentionSuggestionType.room,
      label: 'room',
      displayName: 'Room',
      subtitle: 'Matrix-style room mention',
    ),
    ChatMentionSuggestion(
      type: ChatMentionSuggestionType.room,
      label: 'channel',
      displayName: 'Channel',
      subtitle: 'Broadcast to this channel',
    ),
    ChatMentionSuggestion(
      type: ChatMentionSuggestionType.room,
      label: 'here',
      displayName: 'Here',
      subtitle: 'Mention active participants',
    ),
  ];

  static ChatMentionTrigger? findTrigger({
    required String text,
    required int cursorOffset,
  }) {
    if (cursorOffset < 0) return null;

    final textBeforeCursor = cursorOffset <= text.length
        ? text.substring(0, cursorOffset)
        : text;
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');
    if (lastAtIndex < 0) return null;

    final isValidTrigger =
        lastAtIndex == 0 ||
        _triggerBoundaryChars.contains(textBeforeCursor[lastAtIndex - 1]);
    if (!isValidTrigger) return null;

    final query = textBeforeCursor.substring(lastAtIndex + 1);
    if (query.contains(' ')) return null;

    return ChatMentionTrigger(triggerPosition: lastAtIndex, query: query);
  }

  static List<ChatMentionSuggestion> buildSuggestions({
    required List<ChatMentionMember> members,
    required String? currentUserId,
    required String query,
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    final specialSuggestions = _roomSuggestions.where((suggestion) {
      if (normalizedQuery.isEmpty) return true;
      return suggestion.label.toLowerCase().contains(normalizedQuery) ||
          suggestion.displayName.toLowerCase().contains(normalizedQuery);
    });

    final userSuggestions = members
        .where((member) => member.id != currentUserId)
        .where((member) {
          if (normalizedQuery.isEmpty) return true;
          return member.name.toLowerCase().contains(normalizedQuery);
        })
        .map(
          (member) => ChatMentionSuggestion(
            type: ChatMentionSuggestionType.user,
            label: member.name,
            displayName: member.name,
            userId: member.id,
            avatarUrl: member.avatarUrl,
          ),
        );

    return [...specialSuggestions, ...userSuggestions];
  }

  static ChatMentionInsertionResult applySuggestion({
    required String text,
    required int triggerPosition,
    required int cursorOffset,
    required ChatMentionSuggestion suggestion,
  }) {
    final beforeTrigger = text.substring(0, triggerPosition);
    final afterCursor = cursorOffset <= text.length
        ? text.substring(cursorOffset)
        : '';
    final newText = '$beforeTrigger${suggestion.insertionText}$afterCursor';
    final newCursorOffset =
        beforeTrigger.length + suggestion.insertionText.length;

    return ChatMentionInsertionResult(
      text: newText,
      cursorOffset: newCursorOffset,
      selection: ChatMentionSelection.fromSuggestion(suggestion),
    );
  }

  static List<ChatMentionSelection> mergeSelection({
    required List<ChatMentionSelection> selections,
    required ChatMentionSelection selection,
  }) {
    final merged = <String, ChatMentionSelection>{
      for (final item in selections) item.key: item,
    };
    merged[selection.key] = selection;
    return merged.values.toList(growable: false);
  }

  static List<ChatMentionSelection> pruneSelections(
    String text,
    List<ChatMentionSelection> selections,
  ) {
    return selections
        .where((selection) => _containsMention(text, selection.mentionText))
        .toList(growable: false);
  }

  static ChatMentionPayload buildPayload({
    required String text,
    List<ChatMentionSelection> selections = const [],
    List<ChatMentionMember> members = const [],
  }) {
    final prunedSelections = pruneSelections(text, selections);
    final mentionedUserIds = <String>{};
    var mentionsRoom = _containsRoomAlias(text);
    final extractedLabels = _extractMentionLabels(text);

    for (final selection in prunedSelections) {
      if (selection.mentionsRoom) {
        mentionsRoom = true;
      }
      if (selection.userId != null && selection.userId!.isNotEmpty) {
        mentionedUserIds.add(selection.userId!);
      }
    }

    for (final label in extractedLabels) {
      if (_roomAliases.contains(label.toLowerCase())) {
        mentionsRoom = true;
        continue;
      }

      for (final member in members) {
        if (member.name.toLowerCase() == label.toLowerCase()) {
          mentionedUserIds.add(member.id);
          break;
        }
      }
    }

    final sortedMentionedUserIds = mentionedUserIds.toList()..sort();
    return ChatMentionPayload(
      mentionedUserIds: sortedMentionedUserIds,
      mentionsRoom: mentionsRoom,
    );
  }

  static bool _containsMention(String text, String mentionText) {
    final pattern = RegExp(
      '(^|[\\s,，。.!！？?:：;；、(（\\[【{｛<《「『])${RegExp.escape(mentionText)}(?=[\\s,，。.!！？?:：;；、)）\\]】}》」』]|'
      r'$)',
      caseSensitive: false,
      multiLine: true,
    );
    return pattern.hasMatch(text);
  }

  static Set<String> _extractMentionLabels(String text) {
    final matches = RegExp(
      r'(^|[\s,，。.!！？?:：;；、(（\[【{｛<《「『])@([^\s,.!?:;，。！？：；、)）\]】}》」』]+)',
      caseSensitive: false,
      multiLine: true,
    ).allMatches(text);

    return matches
        .map((match) => match.group(2)?.trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  static bool _containsRoomAlias(String text) {
    return _roomSuggestions.any(
      (suggestion) => _containsMention(text, suggestion.mentionText),
    );
  }
}
