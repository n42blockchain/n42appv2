import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/quiz_reveal.dart';

void main() {
  group('isQuiz', () {
    test('true only with a correct index', () {
      expect(QuizReveal.isQuiz(0), isTrue);
      expect(QuizReveal.isQuiz(-1), isFalse);
      expect(QuizReveal.isQuiz(null), isFalse);
    });
  });

  group('shouldReveal', () {
    test('never for a normal poll', () {
      expect(
        QuizReveal.shouldReveal(
          correctIndex: null,
          hasVoted: true,
          pollEnded: true,
        ),
        isFalse,
      );
      expect(
        QuizReveal.shouldReveal(
          correctIndex: -1,
          hasVoted: true,
          pollEnded: true,
        ),
        isFalse,
      );
    });

    test('reveals after voting or when ended', () {
      expect(
        QuizReveal.shouldReveal(
          correctIndex: 1,
          hasVoted: true,
          pollEnded: false,
        ),
        isTrue,
      );
      expect(
        QuizReveal.shouldReveal(
          correctIndex: 1,
          hasVoted: false,
          pollEnded: true,
        ),
        isTrue,
      );
      expect(
        QuizReveal.shouldReveal(
          correctIndex: 1,
          hasVoted: false,
          pollEnded: false,
        ),
        isFalse,
      );
    });
  });

  group('optionState', () {
    const ids = ['a', 'b', 'c'];

    test('none when not revealing', () {
      expect(
        QuizReveal.optionState(
          optionIndex: 0,
          optionId: 'a',
          correctIndex: 0,
          myVoteIds: const [],
          reveal: false,
        ),
        QuizOptionState.none,
      );
    });

    test('none for invalid negative correct index', () {
      expect(
        QuizReveal.optionState(
          optionIndex: 0,
          optionId: 'a',
          correctIndex: -1,
          myVoteIds: const ['a'],
          reveal: true,
        ),
        QuizOptionState.none,
      );
    });

    test('marks correct, wrong-picked and neutral', () {
      // correct = index 1 ('b'); user picked 'a' (wrong)
      QuizOptionState stateFor(int i) => QuizReveal.optionState(
        optionIndex: i,
        optionId: ids[i],
        correctIndex: 1,
        myVoteIds: const ['a'],
        reveal: true,
      );
      expect(stateFor(1), QuizOptionState.correct);
      expect(stateFor(0), QuizOptionState.wrongPicked);
      expect(stateFor(2), QuizOptionState.neutral);
    });
  });

  group('isAnswerCorrect', () {
    const ids = ['a', 'b', 'c'];

    test('true when correct option is among my votes', () {
      expect(
        QuizReveal.isAnswerCorrect(
          correctIndex: 2,
          optionIds: ids,
          myVoteIds: const ['c'],
        ),
        isTrue,
      );
    });

    test('false when correct option not picked', () {
      expect(
        QuizReveal.isAnswerCorrect(
          correctIndex: 2,
          optionIds: ids,
          myVoteIds: const ['a'],
        ),
        isFalse,
      );
    });

    test('guards null and out-of-range index', () {
      expect(
        QuizReveal.isAnswerCorrect(
          correctIndex: null,
          optionIds: ids,
          myVoteIds: const ['a'],
        ),
        isFalse,
      );
      expect(
        QuizReveal.isAnswerCorrect(
          correctIndex: 9,
          optionIds: ids,
          myVoteIds: const ['a'],
        ),
        isFalse,
      );
    });
  });
}
