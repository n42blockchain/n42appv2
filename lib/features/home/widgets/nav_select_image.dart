import 'dart:io';
import 'dart:typed_data';

import 'package:n42_wallet/features/component/pages/image_crop_page.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:n42_wallet/generated/l10n.dart';

class NavSelectImage extends StatelessWidget {
  final dynamic returnImage;//选择好图片后，返回，返回类型未uint8List
  const NavSelectImage({this.returnImage,super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final navigator = Navigator.of(context);
            //拍照
            XFile? result =
            await ImagePicker().pickImage(source: ImageSource.camera);
            if(!context.mounted) return;
            if (result != null) {
              File file = File(result.path);
              debugPrint("file path-->  ${file.path}");
              Uint8List imageData=await file.readAsBytes();
              Uint8List? rImageData=await navigator.push(
                MaterialPageRoute(builder: (context)=>ImageCropPage(imageData)),
              );
              if(!context.mounted || rImageData == null) return;
              if(returnImage!=null)returnImage(rImageData);
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
            final navigator = Navigator.of(context);
            //从相册选择
            FilePickerResult? result =
            await FilePicker.platform.pickFiles(type: FileType.image);
            if(!context.mounted) return;
            final path = result?.files.single.path;
            if (path != null) {
              File file = File(path);
              debugPrint("file path-->  ${file.path}");
              Uint8List imageData=await file.readAsBytes();
              Uint8List? rImageData=await navigator.push(
                MaterialPageRoute(builder: (context)=>ImageCropPage(imageData)),
              );
              if(!context.mounted || rImageData == null) return;
              if(returnImage!=null)returnImage(rImageData);
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
