/// Quiz 单选项的揭晓状态
enum QuizOptionState {
  /// 非 Quiz / 尚未揭晓
  none,

  /// 正确答案
  correct,

  /// 用户选错的选项
  wrongPicked,

  /// 普通选项（未选、且非正确答案）
  neutral,
}

/// Quiz 答题揭晓纯逻辑（无 IO，便于单测）
///
/// 约定：投票消息携带 `quizCorrectIndex`（正确选项序号）即为 Quiz。
/// 揭晓时机：用户已投票（[hasVoted]）或投票已结束（[pollEnded]）。
class QuizReveal {
  QuizReveal._();

  /// 是否为 Quiz（有正确答案序号）
  static bool isQuiz(int? correctIndex) => correctIndex != null;

  /// 是否应揭晓答案：已投票或已结束
  static bool shouldReveal({
    required int? correctIndex,
    required bool hasVoted,
    required bool pollEnded,
  }) {
    if (correctIndex == null) return false;
    return hasVoted || pollEnded;
  }

  /// 计算某个选项（[optionIndex]，对应 [optionId]）的揭晓状态。
  ///
  /// [correctIndex] 正确序号；[myVoteIds] 用户已选的选项 id 集合。
  static QuizOptionState optionState({
    required int optionIndex,
    required String optionId,
    required int? correctIndex,
    required Iterable<String> myVoteIds,
    required bool reveal,
  }) {
    if (correctIndex == null || !reveal) return QuizOptionState.none;
    if (optionIndex == correctIndex) return QuizOptionState.correct;
    if (myVoteIds.contains(optionId)) return QuizOptionState.wrongPicked;
    return QuizOptionState.neutral;
  }

  /// 用户本次作答是否正确（正确选项 id == 用户所选其一）。
  /// 多选时要求选中正确项且未选错项才算对；这里采用「选中正确项即对」的宽松判定。
  static bool isAnswerCorrect({
    required int? correctIndex,
    required List<String> optionIds,
    required Iterable<String> myVoteIds,
  }) {
    if (correctIndex == null) return false;
    if (correctIndex < 0 || correctIndex >= optionIds.length) return false;
    return myVoteIds.contains(optionIds[correctIndex]);
  }
}
