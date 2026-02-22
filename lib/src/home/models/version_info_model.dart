class VersionInfoModel {
  String? versionName;
  int? versionCode;
  String? updateTitle;
  String? updateContent;

  /// 是否强制更新
  bool? isForce;

  /// 自定义下载链接（兼容 TestFlight / 直接 APK 分发）。
  /// - TestFlight 示例：https://testflight.apple.com/join/XXXXXX
  /// - 直接 APK：https://example.com/app-release.apk
  /// - 为 null 或空字符串时回退到 App Store / Play Store。
  String? downloadUrl;

  VersionInfoModel({
    this.versionName,
    this.versionCode,
    this.updateTitle,
    this.updateContent,
    this.isForce,
    this.downloadUrl,
  });

  VersionInfoModel.fromJson(Map<String, dynamic> map) {
    versionName = map['versionName'] as String?;
    versionCode = map['versionCode'] as int?;
    updateTitle = map['updateTitle'] as String?;
    updateContent = map['updateContent'] as String?;
    isForce = map['isForce'] as bool?;
    downloadUrl = map['downloadUrl'] as String?;
  }

  Map<String, dynamic> toJson() => {
        "versionName": versionName,
        "versionCode": versionCode,
        "updateTitle": updateTitle,
        "updateContent": updateContent,
        "isForce": isForce,
        "downloadUrl": downloadUrl,
      };
}
