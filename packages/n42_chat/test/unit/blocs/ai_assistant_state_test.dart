// Tests for AiAssistantState in ai_assistant_state.dart.
// AiAssistantEntity / AiChatMessage require domain construction;
// those fields are kept null/empty.
// Four clear flags are exercised: clearError, clearSummary,
// clearRewrite, clearLinkSummary.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/ai_assistant/ai_assistant_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Constructor defaults
  // ─────────────────────────────────────────────────

  group('AiAssistantState constructor defaults', () {
    const s = AiAssistantState();

    test('assistant defaults to null', () {
      expect(s.assistant, isNull);
    });

    test('messages defaults to empty list', () {
      expect(s.messages, isEmpty);
    });

    test('isLoading defaults to false', () {
      expect(s.isLoading, isFalse);
    });

    test('isGenerating defaults to false', () {
      expect(s.isGenerating, isFalse);
    });

    test('streamingText defaults to empty string', () {
      expect(s.streamingText, '');
    });

    test('error defaults to null', () {
      expect(s.error, isNull);
    });

    test('summaryResult defaults to null', () {
      expect(s.summaryResult, isNull);
    });

    test('isSummarizing defaults to false', () {
      expect(s.isSummarizing, isFalse);
    });

    test('rewriteResult defaults to null', () {
      expect(s.rewriteResult, isNull);
    });

    test('isRewriting defaults to false', () {
      expect(s.isRewriting, isFalse);
    });

    test('linkSummaryResult defaults to null', () {
      expect(s.linkSummaryResult, isNull);
    });

    test('isSummarizingLink defaults to false', () {
      expect(s.isSummarizingLink, isFalse);
    });

    test('isAvailable defaults to false', () {
      expect(s.isAvailable, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // AiAssistantState.initial()
  // ─────────────────────────────────────────────────

  group('AiAssistantState.initial()', () {
    test('isLoading is true', () {
      expect(AiAssistantState.initial().isLoading, isTrue);
    });

    test('isGenerating is false', () {
      expect(AiAssistantState.initial().isGenerating, isFalse);
    });

    test('error is null', () {
      expect(AiAssistantState.initial().error, isNull);
    });

    test('isAvailable is false', () {
      expect(AiAssistantState.initial().isAvailable, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — scalar overrides
  // ─────────────────────────────────────────────────

  group('AiAssistantState.copyWith scalar', () {
    const base = AiAssistantState(
      isLoading: true,
      isGenerating: false,
      streamingText: 'thinking...',
      error: 'api error',
      summaryResult: 'summary text',
      isSummarizing: false,
      rewriteResult: 'rewritten text',
      isRewriting: false,
      linkSummaryResult: 'link summary',
      isSummarizingLink: false,
      isAvailable: true,
    );

    test('no overrides preserves all fields', () {
      final copy = base.copyWith();
      expect(copy.isLoading, isTrue);
      expect(copy.streamingText, 'thinking...');
      expect(copy.error, 'api error');
      expect(copy.summaryResult, 'summary text');
      expect(copy.isAvailable, isTrue);
    });

    test('overrides isLoading', () {
      final copy = base.copyWith(isLoading: false);
      expect(copy.isLoading, isFalse);
    });

    test('overrides isGenerating', () {
      final copy = base.copyWith(isGenerating: true);
      expect(copy.isGenerating, isTrue);
    });

    test('overrides streamingText', () {
      final copy = base.copyWith(streamingText: 'response text');
      expect(copy.streamingText, 'response text');
    });

    test('overrides summaryResult', () {
      final copy = base.copyWith(summaryResult: 'new summary');
      expect(copy.summaryResult, 'new summary');
    });

    test('overrides isSummarizing', () {
      final copy = base.copyWith(isSummarizing: true);
      expect(copy.isSummarizing, isTrue);
    });

    test('overrides rewriteResult', () {
      final copy = base.copyWith(rewriteResult: 'better text');
      expect(copy.rewriteResult, 'better text');
    });

    test('overrides isRewriting', () {
      final copy = base.copyWith(isRewriting: true);
      expect(copy.isRewriting, isTrue);
    });

    test('overrides linkSummaryResult', () {
      final copy = base.copyWith(linkSummaryResult: 'link summary updated');
      expect(copy.linkSummaryResult, 'link summary updated');
    });

    test('overrides isSummarizingLink', () {
      final copy = base.copyWith(isSummarizingLink: true);
      expect(copy.isSummarizingLink, isTrue);
    });

    test('overrides isAvailable', () {
      final copy = base.copyWith(isAvailable: false);
      expect(copy.isAvailable, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearError flag
  // ─────────────────────────────────────────────────

  group('AiAssistantState.copyWith clearError', () {
    const withError = AiAssistantState(error: 'API timeout');

    test('clearError=true sets error to null', () {
      final copy = withError.copyWith(clearError: true);
      expect(copy.error, isNull);
    });

    test('clearError=false preserves error', () {
      final copy = withError.copyWith(clearError: false);
      expect(copy.error, 'API timeout');
    });

    test('clearError=true overrides provided error', () {
      final copy = withError.copyWith(clearError: true, error: 'ignored');
      expect(copy.error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearSummary flag
  // ─────────────────────────────────────────────────

  group('AiAssistantState.copyWith clearSummary', () {
    const withSummary = AiAssistantState(summaryResult: 'meeting recap');

    test('clearSummary=true sets summaryResult to null', () {
      final copy = withSummary.copyWith(clearSummary: true);
      expect(copy.summaryResult, isNull);
    });

    test('clearSummary=false preserves summaryResult', () {
      final copy = withSummary.copyWith(clearSummary: false);
      expect(copy.summaryResult, 'meeting recap');
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearRewrite flag
  // ─────────────────────────────────────────────────

  group('AiAssistantState.copyWith clearRewrite', () {
    const withRewrite = AiAssistantState(rewriteResult: 'improved version');

    test('clearRewrite=true sets rewriteResult to null', () {
      final copy = withRewrite.copyWith(clearRewrite: true);
      expect(copy.rewriteResult, isNull);
    });

    test('clearRewrite=false preserves rewriteResult', () {
      final copy = withRewrite.copyWith(clearRewrite: false);
      expect(copy.rewriteResult, 'improved version');
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearLinkSummary flag
  // ─────────────────────────────────────────────────

  group('AiAssistantState.copyWith clearLinkSummary', () {
    const withLinkSummary = AiAssistantState(linkSummaryResult: 'article tldr');

    test('clearLinkSummary=true sets linkSummaryResult to null', () {
      final copy = withLinkSummary.copyWith(clearLinkSummary: true);
      expect(copy.linkSummaryResult, isNull);
    });

    test('clearLinkSummary=false preserves linkSummaryResult', () {
      final copy = withLinkSummary.copyWith(clearLinkSummary: false);
      expect(copy.linkSummaryResult, 'article tldr');
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('AiAssistantState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const AiAssistantState(), equals(const AiAssistantState()));
    });

    test('different isLoading → not equal', () {
      expect(
        const AiAssistantState(isLoading: true),
        isNot(equals(const AiAssistantState())),
      );
    });

    test('different streamingText → not equal', () {
      expect(
        const AiAssistantState(streamingText: 'text'),
        isNot(equals(const AiAssistantState())),
      );
    });

    test('different summaryResult → not equal', () {
      expect(
        const AiAssistantState(summaryResult: 'summary'),
        isNot(equals(const AiAssistantState())),
      );
    });

    test('different isAvailable → not equal', () {
      expect(
        const AiAssistantState(isAvailable: true),
        isNot(equals(const AiAssistantState())),
      );
    });

    test('same fields → equal', () {
      expect(
        const AiAssistantState(isGenerating: true, streamingText: 'hi'),
        equals(const AiAssistantState(isGenerating: true, streamingText: 'hi')),
      );
    });
  });
}
