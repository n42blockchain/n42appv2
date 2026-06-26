import 'package:equatable/equatable.dart';

/// Actions that can earn points
enum PointsAction {
  sendMessage,
  sendMedia,
  createThread,
  receiveReaction,
  dailyLogin,
  inviteUser,
  holdToken,
  voteInProposal,
  consecutiveDay,
}

/// A rule defining how points are awarded for an action.
class RewardRule extends Equatable {
  final String id;
  final PointsAction action;
  final int points;
  final int? dailyLimit;
  final Duration? cooldown;
  final bool isEnabled;

  const RewardRule({
    required this.id,
    required this.action,
    required this.points,
    this.dailyLimit,
    this.cooldown,
    this.isEnabled = true,
  });

  /// Human-readable label for the action type
  String get actionLabel {
    switch (action) {
      case PointsAction.sendMessage:
        return 'Send Message';
      case PointsAction.sendMedia:
        return 'Send Media';
      case PointsAction.createThread:
        return 'Create Thread';
      case PointsAction.receiveReaction:
        return 'Receive Reaction';
      case PointsAction.dailyLogin:
        return 'Daily Login';
      case PointsAction.inviteUser:
        return 'Invite User';
      case PointsAction.holdToken:
        return 'Hold Token';
      case PointsAction.voteInProposal:
        return 'Vote in Proposal';
      case PointsAction.consecutiveDay:
        return 'Consecutive Day';
    }
  }

  @override
  List<Object?> get props => [id, action, points, dailyLimit, cooldown, isEnabled];
}
