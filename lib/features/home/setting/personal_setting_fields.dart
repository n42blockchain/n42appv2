// ignore_for_file: invalid_use_of_protected_member
part of 'personal_setting.dart';

extension on _PersonalSettingState {
  // ── 主题色快捷访问 ──────────────────────────────────────────────────────────
  Color get _blueColor => AppColorTokens.of(context).brand;
  Color get _subtitleColor => AppColorTokens.of(context).textSubtitle;

  TextStyle get _subtitleStyle =>
      AppTypography.body.copyWith(color: _subtitleColor);

  // ── Avatar (只读) ──────────────────────────────────────────────────────────

  Widget buildAvatar() {
    final size = ScreenUtil().setWidth(132.0);
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(60.0)),
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: ImageNetWork(
          imageUrl: userInfo?.image ?? "",
          placeholder: "assets/img/person_def_1.png",
        ),
      ),
    );
  }

  // ── Info rows ───────────────────────────────────────────────────────────────

  Widget buildEmailRow() {
    return _buildInfoRowContainer(
      child: Text(userInfo?.email ?? '', style: _subtitleStyle),
    );
  }

  Widget buildInviteCodeRow() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingShare()),
      ),
      child: _buildInfoRowContainer(
        child: Row(
          children: [
            Expanded(
              child: Text(userInfo?.inviteCode ?? '', style: _subtitleStyle),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: userInfo?.inviteCode ?? ''),
                );
                ToastUtils.showSuccess(S.of(context).copy);
              },
              child: Icon(
                Icons.copy,
                color: _blueColor,
                size: ScreenUtil().setSp(32.0),
              ),
            ),
            SizedBox(width: AppSpacing.space2),
            Icon(
              Icons.chevron_right,
              color: _subtitleColor,
              size: ScreenUtil().setSp(36.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUuidRow() {
    return _buildInfoRowContainer(
      child: Text(userInfo?.uuid ?? "", style: _subtitleStyle),
    );
  }

  Widget buildEnsRow() {
    return _buildInfoRowContainer(
      child: _ensLoading
          ? SizedBox(
              width: ScreenUtil().setSp(32.0),
              height: ScreenUtil().setSp(32.0),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _blueColor,
              ),
            )
          : Text(
              _ensName ?? '—',
              style: AppTypography.body.copyWith(
                color: _ensName != null ? _blueColor : _subtitleColor,
              ),
            ),
    );
  }

  Widget _buildInfoRowContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
      decoration: _bottomBorder,
      child: child,
    );
  }
}
