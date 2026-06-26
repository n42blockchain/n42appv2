/// BLoC 层使用的消息 key 常量
///
/// BLoC 无 BuildContext，不能直接使用 l10n。
/// 此类定义静态常量 key，UI 层在 BlocListener 中通过
/// [BlocMessageHelper.resolve] 将 key 映射为本地化文本。
class BlocMessageKeys {
  BlocMessageKeys._();

  // Group
  static const groupNotFound = 'group_not_found';
  static const groupNameUpdated = 'group_name_updated';
  static const groupDescriptionUpdated = 'group_description_updated';
  static const groupAvatarUpdated = 'group_avatar_updated';
  static const groupVisibilityUpdated = 'group_visibility_updated';
  static const groupChannelCreated = 'group_channel_created';
  static const groupChannelUpdated = 'group_channel_updated';
  static const groupChannelDeleted = 'group_channel_deleted';
  static const groupMembersInvited = 'group_members_invited';
  static const groupMemberRemoved = 'group_member_removed';
  static const groupSetAsAdmin = 'group_set_as_admin';
  static const groupAdminRemoved = 'group_admin_removed';
  static const groupLeft = 'group_left';
  static const groupDisbanded = 'group_disbanded';
  static const groupJoined = 'group_joined';
  static const groupInviteDeclined = 'group_invite_declined';
  static const groupTokenGateUpdated = 'group_token_gate_updated';
  static const groupMaxMembersUpdated = 'group_max_members_updated';
  static const groupFull = 'group_full';
  static const groupContentFilterUpdated = 'group_content_filter_updated';
  static const groupBotConfigUpdated = 'group_bot_config_updated';
  static const chatReportSuccess = 'chat_report_success';

  // Transfer
  static const transferProcessing = 'transfer_processing';
  static const transferCancelled = 'transfer_cancelled';
  static const transferFailed = 'transfer_failed';
  static const paymentProcessing = 'payment_processing';
  static const paymentFailed = 'payment_failed';

  // Auth — password reset
  static const authSendVerificationCodeFailed = 'auth_send_verification_code_failed';
  static const authServerNoEmailPasswordReset = 'auth_server_no_email_password_reset';
  static const authResetPasswordFailed = 'auth_reset_password_failed';

  // Auth — password change
  static const authChangePasswordFailed = 'auth_change_password_failed';
  static const authOldPasswordWrong = 'auth_old_password_wrong';

  // Auth — social login
  static const authLoginCancelled = 'auth_login_cancelled';
  static const authGoogleLoginFailed = 'auth_google_login_failed';
  static const authAppleLoginFailed = 'auth_apple_login_failed';
  static const authSsoLoginFailed = 'auth_sso_login_failed';
  static const authFacebookLoginFailed = 'auth_facebook_login_failed';
  static const authTwitterLoginFailed = 'auth_twitter_login_failed';
  static const authWeChatLoginFailed = 'auth_wechat_login_failed';
  static const authWeChatNotConfigured = 'auth_wechat_not_configured';
  static const authWeChatNotInstalled = 'auth_wechat_not_installed';

  // Auth — email
  static const authPasswordWrong = 'auth_password_wrong';
  static const authEmailAlreadyBound = 'auth_email_already_bound';
  static const authChangeEmailFailed = 'auth_change_email_failed';
  static const authVerificationCodeInvalid = 'auth_verification_code_invalid';

  // Auth — session
  static const authSessionExpired = 'auth_session_expired';
  static const authSessionIncomplete = 'auth_session_incomplete';

}
