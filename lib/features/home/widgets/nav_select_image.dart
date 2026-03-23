import 'dart:io';
import 'dart:typed_data';

import 'package:n42_wallet/features/component/pages/image_crop_page.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:n42_wallet/generated/l10n.dart';

class NavSelectImage extends StatelessWidget {
  final ValueChanged<Uint8List?>? returnImage;
  const NavSelectImage({this.returnImage,super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            //拍照
            XFile? result =
            await ImagePicker().pickImage(source: ImageSource.camera);
            if(!context.mounted) return;
            if (result != null) {
              File file = File(result.path);
              debugPrint("file path-->  ${file.path}");
              //final filePath = file.absolute.path;
              Uint8List imageData=file.readAsBytesSync();
              Uint8List? rImageData=await Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageCropPage(imageData)));
              if(!context.mounted) return;
              returnImage?.call(rImageData);
            }
          },
          child: Container(
              color: Colors.transparent,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Text(
                S.of(context).photograph,
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: 16),
              )),
        ),
        Divider(
          height: 1,
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        GestureDetector(
          onTap: () async {
            //从相册选择
            FilePickerResult? result =
            await FilePicker.platform.pickFiles(type: FileType.image);
            if(!context.mounted) return;
            if (result != null) {
              File file = File(result.files.single.path!);
              debugPrint("file path-->  ${file.path}");
              //final filePath = file.absolute.path;
              Uint8List imageData=file.readAsBytesSync();
              Uint8List? rImageData=await Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageCropPage(imageData)));
              if(!context.mounted) return;
              returnImage?.call(rImageData);
            }
          },
          child: Container(
              color: Colors.transparent,
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                S.of(context).g_key_personal_1,
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: 16),
              )),
        ),
        Divider(
          height: 1,
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
              color: Colors.transparent,
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                S.of(context).g_key_79,
                style: const TextStyle(fontSize: 16),
              )),
        ),
      ],
    );
  }
}
