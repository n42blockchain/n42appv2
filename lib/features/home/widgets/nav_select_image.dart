import 'dart:io';
import 'dart:typed_data';

import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/component/pages/image_crop_page.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:n42_wallet/generated/l10n.dart';

class NavSelectImage extends StatelessWidget {
  final ValueChanged<Uint8List?>? returnImage;
  const NavSelectImage({this.returnImage, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            final navigator = Navigator.of(context);
            //拍照
            XFile? result = await ImagePicker().pickImage(
              source: ImageSource.camera,
            );
            if (!context.mounted) return;
            if (result != null) {
              File file = File(result.path);
              AppLogger.d('NavSelectImage', 'file path: ${file.path}');
              Uint8List imageData = await file.readAsBytes();
              if (!context.mounted) return;
              Uint8List? rImageData = await navigator.push(
                MaterialPageRoute(
                  builder: (context) => ImageCropPage(imageData),
                ),
              );
              if (!context.mounted) return;
              returnImage?.call(rImageData);
            }
          },
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.space6),
            alignment: Alignment.center,
            child: Text(
              S.of(context).photograph,
              style: AppTypography.headline.copyWith(
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
          ),
        ),
        Divider(height: 1, color: AppColorTokens.of(context).border),
        InkWell(
          onTap: () async {
            final navigator = Navigator.of(context);
            //从相册选择
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.image,
            );
            if (!context.mounted) return;
            final path = result?.files.single.path;
            if (path != null) {
              File file = File(path);
              AppLogger.d('NavSelectImage', 'file path: ${file.path}');
              Uint8List imageData = await file.readAsBytes();
              if (!context.mounted) return;
              Uint8List? rImageData = await navigator.push(
                MaterialPageRoute(
                  builder: (context) => ImageCropPage(imageData),
                ),
              );
              if (!context.mounted) return;
              returnImage?.call(rImageData);
            }
          },
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.space6),
            child: Text(
              S.of(context).g_key_personal_1,
              style: AppTypography.headline.copyWith(
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
          ),
        ),
        Divider(height: 1, color: AppColorTokens.of(context).border),
        InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.space6),
            child: Text(
              S.of(context).g_key_79,
              style: AppTypography.headline.copyWith(
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
