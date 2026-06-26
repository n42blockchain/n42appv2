import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';
import '../blocs/bloc_message_keys.dart';

/// 将 BLoC 层的消息 key 映射为本地化文本
///
/// BLoC 无 BuildContext，使用 [BlocMessageKeys] 常量代替硬编码字符串。
/// UI 层在 BlocListener 中调用此方法将 key 翻译为用户可读文本。
String resolveBlocMessage(BuildContext context, String key) {
  final l10n = S.of(context);
  if (l10n == null) return key;

  // 处理带参数的 key（格式：key:param）
  if (key.startsWith(BlocMessageKeys.groupMembersInvited)) {
    final parts = key.split(':');
    if (parts.length == 2) {
      final count = int.tryParse(parts[1]) ?? 0;
      return l10n.blocGroupMembersInvited(count);
    }
  }

  switch (key) {
    // Group
    case BlocMessageKeys.groupNotFound:
      return l10n.blocGroupNotFound;
    case BlocMessageKeys.groupNameUpdated:
      return l10n.chatGroupNameUpdated;
    case BlocMessageKeys.groupDescriptionUpdated:
      return l10n.groupDescriptionUpdated;
    case BlocMessageKeys.groupAvatarUpdated:
      return l10n.groupAvatarUpdated;
    case BlocMessageKeys.groupVisibilityUpdated:
      return l10n.groupVisibilityUpdated;
    case BlocMessageKeys.groupChannelCreated:
      return l10n.groupChannelCreated;
    case BlocMessageKeys.groupChannelUpdated:
      return l10n.groupChannelUpdated;
    case BlocMessageKeys.groupChannelDeleted:
      return l10n.groupChannelDeleted;
    case BlocMessageKeys.groupMemberRemoved:
      return l10n.blocGroupMemberRemoved;
    case BlocMessageKeys.groupSetAsAdmin:
      return l10n.groupSetAsAdmin;
    case BlocMessageKeys.groupAdminRemoved:
      return l10n.blocGroupAdminRemoved;
    case BlocMessageKeys.groupLeft:
      return l10n.blocGroupLeft;
    case BlocMessageKeys.groupDisbanded:
      return l10n.blocGroupDisbanded;
    case BlocMessageKeys.groupJoined:
      return l10n.blocGroupJoined;
    case BlocMessageKeys.groupInviteDeclined:
      return l10n.blocGroupInviteDeclined;
    case BlocMessageKeys.groupTokenGateUpdated:
      return l10n.blocGroupTokenGateUpdated;
    case BlocMessageKeys.groupMaxMembersUpdated:
      return l10n.groupMaxMembersUpdated;
    case BlocMessageKeys.groupFull:
      return l10n.groupFull;
    case BlocMessageKeys.groupContentFilterUpdated:
      return l10n.groupContentFilterUpdated;
    case BlocMessageKeys.groupBotConfigUpdated:
      return l10n.groupBotConfigUpdated;
    case BlocMessageKeys.chatReportSuccess:
      return l10n.chatReportSuccess;

    // Transfer
    case BlocMessageKeys.transferProcessing:
      return l10n.blocTransferProcessing;
    case BlocMessageKeys.transferCancelled:
      return l10n.blocTransferCancelled;
    case BlocMessageKeys.transferFailed:
      return l10n.blocTransferFailed;
    case BlocMessageKeys.paymentProcessing:
      return l10n.blocPaymentProcessing;
    case BlocMessageKeys.paymentFailed:
      return l10n.blocPaymentFailed;

    // Auth — password
    case BlocMessageKeys.authSendVerificationCodeFailed:
      return l10n.blocAuthSendVerificationCodeFailed;
    case BlocMessageKeys.authServerNoEmailPasswordReset:
      return l10n.blocAuthServerNoEmailPasswordReset;
    case BlocMessageKeys.authResetPasswordFailed:
      return l10n.blocAuthResetPasswordFailed;
    case BlocMessageKeys.authChangePasswordFailed:
      return l10n.blocAuthChangePasswordFailed;
    case BlocMessageKeys.authOldPasswordWrong:
      return l10n.blocAuthOldPasswordWrong;

    // Auth — social login
    case BlocMessageKeys.authLoginCancelled:
      return l10n.blocAuthLoginCancelled;
    case BlocMessageKeys.authGoogleLoginFailed:
      return l10n.blocAuthGoogleLoginFailed;
    case BlocMessageKeys.authAppleLoginFailed:
      return l10n.blocAuthAppleLoginFailed;
    case BlocMessageKeys.authSsoLoginFailed:
      return l10n.blocAuthSsoLoginFailed;
    case BlocMessageKeys.authFacebookLoginFailed:
      return l10n.blocAuthFacebookLoginFailed;
    case BlocMessageKeys.authTwitterLoginFailed:
      return l10n.blocAuthTwitterLoginFailed;
    case BlocMessageKeys.authWeChatLoginFailed:
      return l10n.blocAuthWeChatLoginFailed;
    case BlocMessageKeys.authWeChatNotConfigured:
      return l10n.blocAuthWeChatNotConfigured;
    case BlocMessageKeys.authWeChatNotInstalled:
      return l10n.blocAuthWeChatNotInstalled;

    // Auth — email
    case BlocMessageKeys.authPasswordWrong:
      return l10n.blocAuthPasswordWrong;
    case BlocMessageKeys.authEmailAlreadyBound:
      return l10n.blocAuthEmailAlreadyBound;
    case BlocMessageKeys.authChangeEmailFailed:
      return l10n.blocAuthChangeEmailFailed;
    case BlocMessageKeys.authVerificationCodeInvalid:
      return l10n.blocAuthVerificationCodeInvalid;

    // Auth — session
    case BlocMessageKeys.authSessionExpired:
      return l10n.blocAuthSessionExpired;
    case BlocMessageKeys.authSessionIncomplete:
      return l10n.blocAuthSessionIncomplete;

    default:
      return key;
  }
}
