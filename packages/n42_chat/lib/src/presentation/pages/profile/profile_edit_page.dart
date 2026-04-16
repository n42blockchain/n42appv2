import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/avatar_decoration_preset.dart';
import '../../../domain/entities/user_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/common_widgets.dart';
import 'avatar_studio_page.dart';
import 'profile_address_manage_page.dart';
import 'profile_invoice_manage_page.dart';
import 'profile_ringtone_select_page.dart';

import 'n42_bean_page.dart';
import '../../../core/utils/debug_log.dart';

/// 个人资料编辑页面
///
/// 微信风格的个人资料设置页面
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

enum _PendingProfileOperation {
  avatar,
  displayName,
  gender,
  region,
  pokeText,
  signature,
  ringtone,
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final ImagePicker _imagePicker = ImagePicker();
  _PendingProfileOperation? _pendingOperation;
  String? _pendingSuccessMessage;
  String? _pendingErrorFallback;

  bool get _isUploading => _pendingOperation == _PendingProfileOperation.avatar;

  @override
  void initState() {
    super.initState();
    // 加载用户资料数据
    context.read<AuthBloc>().add(const LoadUserProfileData());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        debugLog(
          'ProfileEditPage: AuthState changed - status: ${state.status}, pendingOperation: $_pendingOperation',
        );

        if (_pendingOperation == null) {
          return;
        }

        if (state.status == AuthStatus.authenticated) {
          final successMessage = _pendingSuccessMessage;
          setState(() {
            _pendingOperation = null;
            _pendingSuccessMessage = null;
            _pendingErrorFallback = null;
          });
          if (successMessage != null && successMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(successMessage),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (state.status == AuthStatus.error) {
          final errorMessage = state.errorMessage ?? _pendingErrorFallback;
          debugLog('ProfileEditPage: Profile operation failed - $errorMessage');
          setState(() {
            _pendingOperation = null;
            _pendingSuccessMessage = null;
            _pendingErrorFallback = null;
          });
          if (errorMessage != null && errorMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final user = state.user;

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : const Color(0xFFF5F5F5),
          appBar: N42AppBar(
            title: S.of(context)?.profilePersonalProfile ?? 'Personal Profile',
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
          ),
          body: ListView(
            children: [
              const SizedBox(height: 10),

              // 基本信息区块
              _buildSection(
                isDark: isDark,
                children: [
                  // 头像
                  _buildListTile(
                    isDark: isDark,
                    title: S.of(context)?.profileAvatar ?? 'Avatar',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isUploading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          N42Avatar(
                            name: user?.displayName ?? '',
                            imageUrl: user?.avatarUrl,
                            size: 60,
                            isNftAvatar: user?.hasNftAvatar ?? false,
                            decorationPreset:
                                user?.avatarDecorationPreset ??
                                AvatarDecorationPreset.none,
                          ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                    onTap: _pickAvatar,
                  ),
                  _buildDivider(isDark),

                  _buildListTile(
                    isDark: isDark,
                    title: 'Avatar Studio',
                    value: _avatarStudioLabel(user),
                    onTap: _openAvatarStudio,
                  ),
                  _buildDivider(isDark),

                  // 名字
                  _buildListTile(
                    isDark: isDark,
                    title: S.of(context)?.profileName ?? 'Name',
                    value:
                        user?.displayName ??
                        (S.of(context)?.commonNotSet ?? 'Not Set'),
                    onTap: () => _editDisplayName(user?.displayName),
                  ),
                  _buildDivider(isDark),

                  // 性别
                  _buildListTile(
                    isDark: isDark,
                    title: S.of(context)?.profileGender ?? 'Gender',
                    value: _getGenderText(context, user?.gender),
                    onTap: _selectGender,
                  ),
                  _buildDivider(isDark),

                  // 地区
                  _buildListTile(
                    isDark: isDark,
                    title: S.of(context)?.profileRegion ?? 'Region',
                    value:
                        user?.region ??
                        (S.of(context)?.commonNotSet ?? 'Not Set'),
                    onTap: _selectRegion,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 账号信息区块
              _buildSection(
                isDark: isDark,
                children: [
                  // N42 ID
                  _buildListTile(
                    isDark: isDark,
                    title: S.of(context)?.profileN42IdTitle ?? 'N42 ID',
                    value: user?.userId ?? '',
                    showArrow: false,
                  ),
                  _buildDivider(isDark),

                  // 我的二维码
                  _buildListTile(
                    isDark: isDark,
                    title: S.of(context)?.commonMyQrCode ?? 'My QR Code',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code,
                          size: 20,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                    onTap: () => _showMyQRCode(user?.userId ?? ''),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 其他信息区块
              _buildSection(
                isDark: isDark,
                children: [
                  // 拍一拍
                  _buildListTile(
                    isDark: isDark,
                    title: S.of(context)?.profilePoke ?? 'Poke',
                    value: user?.pokeText?.isNotEmpty == true
                        ? user!.pokeText!
                        : (S.of(context)?.commonNotSet ?? 'Not Set'),
                    onTap: () => _editPokeText(user?.pokeText),
                  ),
                  _buildDivider(isDark),

                  // 签名
                  _buildListTile(
                    isDark: isDark,
                    title: S.of(context)?.profileSignature ?? 'Signature',
                    value:
                        user?.signature ??
                        (S.of(context)?.commonNotSet ?? 'Not Set'),
                    onTap: () => _editSignature(user?.signature),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 更多设置区块
              _buildSection(
                isDark: isDark,
                children: [
                  // 来电铃声
                  _buildListTile(
                    isDark: isDark,
                    title: S.of(context)?.profileRingtone ?? 'Ringtone',
                    value:
                        user?.ringtone ??
                        (S.of(context)?.profileDefaultRingtone ??
                            'Default Ringtone'),
                    onTap: () => _selectRingtone(user?.ringtone),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 地址与发票区块
              _buildSection(
                isDark: isDark,
                children: [
                  // 我的地址
                  _buildListTile(
                    isDark: isDark,
                    title: S.of(context)?.profileMyAddresses ?? 'My Addresses',
                    onTap: _manageAddresses,
                  ),
                  _buildDivider(isDark),

                  // 我的发票抬头
                  _buildListTile(
                    isDark: isDark,
                    title: S.of(context)?.profileMyInvoices ?? 'My Invoices',
                    onTap: _manageInvoices,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // N42 Bean区块
              _buildSection(
                isDark: isDark,
                children: [
                  _buildListTile(
                    isDark: isDark,
                    title: S.of(context)?.profileN42Bean ?? 'N42 Bean',
                    onTap: _openN42Bean,
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required bool isDark,
    required String title,
    String? value,
    Widget? trailing,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // 左侧标题 - 不换行
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 16),
            // 右侧内容
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (trailing != null)
                    trailing
                  else ...[
                    if (value != null)
                      Expanded(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    if (showArrow) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(
        height: 1,
        color: isDark ? AppColors.dividerDark : AppColors.divider,
      ),
    );
  }

  String _getGenderText(BuildContext context, String? gender) {
    switch (gender) {
      case 'male':
        return S.of(context)?.profileMale ?? 'Male';
      case 'female':
        return S.of(context)?.profileFemale ?? 'Female';
      default:
        return S.of(context)?.commonNotSet ?? 'Not Set';
    }
  }

  String _avatarStudioLabel(UserEntity? user) {
    final parts = <String>[
      if (user?.hasNftAvatar ?? false) 'NFT',
      if ((user?.avatarDecorationPreset ?? AvatarDecorationPreset.none) !=
          AvatarDecorationPreset.none)
        (user?.avatarDecorationPreset ?? AvatarDecorationPreset.none)
            .displayName,
    ];

    return parts.isEmpty ? 'Customize' : parts.join(' · ');
  }

  void _dispatchProfileOperation({
    required _PendingProfileOperation operation,
    String? successMessage,
    String? errorFallback,
    required void Function(AuthBloc bloc) dispatch,
  }) {
    setState(() {
      _pendingOperation = operation;
      _pendingSuccessMessage = successMessage;
      _pendingErrorFallback = errorFallback;
    });
    dispatch(context.read<AuthBloc>());
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(S.of(context)?.commonTakePhoto ?? 'Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(
                S.of(context)?.profileChooseFromGallery ??
                    'Choose from Gallery',
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(S.of(context)?.commonCancel ?? 'Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      debugLog('ProfileEditPage: Picking image from $source');

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) {
        debugLog('ProfileEditPage: No image selected');
        return;
      }

      debugLog(
        'ProfileEditPage: Image selected: ${image.path}, name: ${image.name}',
      );

      final bytes = await image.readAsBytes();
      debugLog('ProfileEditPage: Image bytes: ${bytes.length}');

      if (!mounted) return;
      if (bytes.isEmpty) {
        throw Exception(
          S.of(context)?.commonImageDataEmpty ?? 'Image data is empty',
        );
      }

      // 确保文件名有正确的扩展名
      String filename = image.name;
      if (!filename.contains('.')) {
        // iOS 相机可能不带扩展名，添加 .jpg
        filename = '$filename.jpg';
      }

      debugLog('ProfileEditPage: Uploading avatar with filename: $filename');

      _dispatchProfileOperation(
        operation: _PendingProfileOperation.avatar,
        successMessage: S.of(context)?.profileAvatarUpdated ?? 'Avatar updated',
        errorFallback:
            S.of(context)?.profileAvatarUploadFailed ?? 'Avatar upload failed',
        dispatch: (bloc) =>
            bloc.add(UpdateAvatar(avatarBytes: bytes, filename: filename)),
      );
    } catch (e, stackTrace) {
      debugLog('ProfileEditPage: Pick image error: $e');
      debugLog('ProfileEditPage: Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _pendingOperation = null;
          _pendingSuccessMessage = null;
          _pendingErrorFallback = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context)?.commonSelectImageFailed ?? 'Failed to select image'}: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _editDisplayName(String? currentName) async {
    final controller = TextEditingController(text: currentName);
    String? result;
    try {
      result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.of(context)?.profileChangeName ?? 'Change Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: S.of(context)?.profileEnterNickname ?? 'Enter nickname',
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(S.of(context)?.commonConfirm ?? 'Confirm'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }

    if (result != null && result.isNotEmpty && result != currentName) {
      final nextDisplayName = result;
      if (!mounted) return;
      _dispatchProfileOperation(
        operation: _PendingProfileOperation.displayName,
        errorFallback: 'Update nickname failed',
        dispatch: (bloc) => bloc.add(UpdateDisplayName(nextDisplayName)),
      );
    }
  }

  Future<void> _selectGender() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                S.of(context)?.profileMale ?? 'Male',
                textAlign: TextAlign.center,
              ),
              onTap: () => Navigator.pop(context, 'male'),
            ),
            const Divider(height: 1),
            ListTile(
              title: Text(
                S.of(context)?.profileFemale ?? 'Female',
                textAlign: TextAlign.center,
              ),
              onTap: () => Navigator.pop(context, 'female'),
            ),
            const Divider(height: 1),
            ListTile(
              title: Text(
                S.of(context)?.commonCancel ?? 'Cancel',
                textAlign: TextAlign.center,
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      final genderText = result == 'male'
          ? (S.of(context)?.profileMale ?? 'Male')
          : (S.of(context)?.profileFemale ?? 'Female');
      _dispatchProfileOperation(
        operation: _PendingProfileOperation.gender,
        successMessage:
            S.of(context)?.profileGenderSetTo(genderText) ??
            'Gender set to: $genderText',
        errorFallback: 'Update profile failed',
        dispatch: (bloc) => bloc.add(UpdateUserProfile(gender: result)),
      );
    }
  }

  Future<void> _selectRegion() async {
    // 世界著名城市 - 按地区分类
    final regions = [
      'North America',
      'Europe',
      'Asia',
      'Oceania',
      'South America',
      'Middle East',
      'Africa',
    ];

    final province = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Text(
                    S.of(context)?.profileSelectRegion ?? 'Select Region',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: regions.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(regions[index]),
                  onTap: () => Navigator.pop(context, regions[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (province != null && mounted) {
      // 选择城市
      final cities = _getCitiesForRegion(province);

      if (cities.isNotEmpty) {
        final city = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          builder: (context) => SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      S.of(context)?.profileSelectCity ?? 'Select City',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: cities.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(cities[index]),
                        onTap: () => Navigator.pop(context, cities[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        if (city != null && mounted) {
          _dispatchProfileOperation(
            operation: _PendingProfileOperation.region,
            successMessage:
                S.of(context)?.profileRegionSetTo(city) ??
                'Region set to: $city',
            errorFallback: 'Update profile failed',
            dispatch: (bloc) => bloc.add(UpdateUserProfile(region: city)),
          );
        }
      }
    }
  }

  List<String> _getCitiesForRegion(String region) {
    // 世界著名城市数据
    final Map<String, List<String>> cityData = {
      'North America': [
        'New York',
        'Los Angeles',
        'Chicago',
        'San Francisco',
        'Miami',
        'Toronto',
        'Vancouver',
        'Mexico City',
      ],
      'Europe': [
        'London',
        'Paris',
        'Berlin',
        'Rome',
        'Madrid',
        'Amsterdam',
        'Barcelona',
        'Vienna',
        'Prague',
        'Zurich',
      ],
      'Asia': [
        'Tokyo',
        'Singapore',
        'Hong Kong',
        'Seoul',
        'Shanghai',
        'Beijing',
        'Bangkok',
        'Mumbai',
        'Taipei',
        'Osaka',
      ],
      'Oceania': ['Sydney', 'Melbourne', 'Auckland', 'Brisbane', 'Perth'],
      'South America': [
        'São Paulo',
        'Rio de Janeiro',
        'Buenos Aires',
        'Lima',
        'Bogotá',
        'Santiago',
      ],
      'Middle East': [
        'Dubai',
        'Abu Dhabi',
        'Tel Aviv',
        'Istanbul',
        'Doha',
        'Riyadh',
      ],
      'Africa': [
        'Cape Town',
        'Cairo',
        'Johannesburg',
        'Nairobi',
        'Casablanca',
        'Lagos',
      ],
    };
    return cityData[region] ?? [];
  }

  Future<void> _editPokeText(String? currentPokeText) async {
    final controller = TextEditingController(text: currentPokeText);
    String? result;
    try {
      result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.of(context)?.profileSetPoke ?? 'Set Poke'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context)?.profileFriendPokedMe ?? 'Friend poked me',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 50,
                decoration: InputDecoration(
                  hintText:
                      S.of(context)?.profileEnterPokeSuffixHint ??
                      'Enter poke suffix, e.g.: on the shoulder',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${S.of(context)?.profileExample ?? 'Example'}: ${S.of(context)?.profileFriendPokedMe ?? 'Friend poked me'}${controller.text.isNotEmpty ? controller.text : (S.of(context)?.profileOnTheShoulder ?? " on the shoulder")}',
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(S.of(context)?.commonConfirm ?? 'Confirm'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }

    if (result != null && mounted) {
      _dispatchProfileOperation(
        operation: _PendingProfileOperation.pokeText,
        successMessage: result.isEmpty
            ? (S.of(context)?.profilePokeCleared ?? 'Poke cleared')
            : (S.of(context)?.profilePokeSetTo(result) ??
                  'Poke set to: poked me$result'),
        errorFallback: 'Update profile failed',
        dispatch: (bloc) => bloc.add(UpdateUserProfile(pokeText: result)),
      );
    }
  }

  Future<void> _editSignature(String? currentSignature) async {
    final controller = TextEditingController(text: currentSignature);
    String? result;
    try {
      result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.of(context)?.profileEditSignature ?? 'Edit Signature'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 50,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  S.of(context)?.profileIntroduceYourself ??
                  'A sentence to introduce yourself',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(S.of(context)?.commonConfirm ?? 'Confirm'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }

    if (result != null && result != currentSignature && mounted) {
      _dispatchProfileOperation(
        operation: _PendingProfileOperation.signature,
        successMessage: result.isEmpty
            ? (S.of(context)?.profileSignatureCleared ?? 'Signature cleared')
            : (S.of(context)?.profileSignatureUpdated ?? 'Signature updated'),
        errorFallback: 'Update profile failed',
        dispatch: (bloc) => bloc.add(UpdateUserProfile(signature: result)),
      );
    }
  }

  Future<void> _showMyQRCode(String userId) async {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context)?.commonMyQrCode ?? 'My QR Code',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QrImageView(
                  data: 'n42chat://user/$userId',
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userId,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                S.of(context)?.profileScanToAddFriend ??
                    'Scan the QR code above to add me as a friend',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectRingtone(String? currentRingtone) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) => RingtoneSelectPage(
          currentRingtone:
              currentRingtone ??
              (S.of(context)?.profileDefaultRingtone ?? 'Default Ringtone'),
        ),
      ),
    );

    if (result != null && result != currentRingtone && mounted) {
      _dispatchProfileOperation(
        operation: _PendingProfileOperation.ringtone,
        successMessage:
            S.of(context)?.profileRingtoneSetTo(result) ??
            'Ringtone set to: $result',
        errorFallback: 'Update profile failed',
        dispatch: (bloc) => bloc.add(UpdateUserProfile(ringtone: result)),
      );
    }
  }

  Future<void> _openAvatarStudio() async {
    final authBloc = context.read<AuthBloc>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: authBloc,
          child: const AvatarStudioPage(),
        ),
      ),
    );
  }

  Future<void> _manageAddresses() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const AddressManagePage()),
    );
  }

  Future<void> _manageInvoices() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const InvoiceManagePage()),
    );
  }

  Future<void> _openN42Bean() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => const N42BeanPage()));
  }
}

/// 地址管理页面
