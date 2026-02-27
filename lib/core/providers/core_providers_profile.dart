// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

part of 'core_providers.dart';

// ============================================
// User Profile Provider
// ============================================

/// Handles user profile editing (avatar upload + info update)
final userProfileProvider = Provider<UserProfileService>((ref) {
  return UserProfileService(ref);
});

class UserProfileService {
  final Ref _ref;

  UserProfileService(this._ref);

  /// Edit user info, optionally uploading a new avatar image
  Future<MessageModel> editUserInfo(UserInfo uInfo, {Uint8List? imageData}) async {
    MessageModel mm = MessageModel();
    if (imageData != null) {
      Map<String, dynamic> rData = await IpfsApi().uploadIPFSImage(
        imageData,
        "aImage.png",
        (int count, int total) {},
        type: 1,
      );
      if (rData["error"]) {
        mm.error = true;
        mm.data = "Upload failed";
        return mm;
      } else {
        uInfo.image = "${AppConfig.apiUrl['ipfsAddress']}${rData['data']['Hash']}";
      }
    }
    Map<String, dynamic> uMap = {
      "desc": uInfo.desc ?? "",
      "image": uInfo.image ?? "",
      "name": uInfo.name ?? "",
    };
    final userInfoAPI = UserInfoApi();
    mm = await userInfoAPI.updateUserInfo(uMap);
    if (mm.error == false) {
      await _ref.read(spUtilProvider).saveUserInfo(uInfo);
      AppGlobals.userInfo = uInfo;
      final sharedInfo = SharedUserInfo(
        uuid: uInfo.uuid ?? '',
        email: uInfo.email ?? '',
        name: uInfo.name,
        avatarUrl: uInfo.image,
        token: uInfo.token,
        image: uInfo.image,
        desc: uInfo.desc,
      );
      _ref.read(currentUserProvider.notifier).setUser(sharedInfo);
    }
    return mm;
  }
}
