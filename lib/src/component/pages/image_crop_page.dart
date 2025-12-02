import 'dart:typed_data';

import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/loading_page.dart';
//import 'package:crop_your_image/crop_your_image.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class ImageCropPage extends StatefulWidget {
  final Uint8List imageData;
  String title;
  ImageCropPage(this.imageData,{this.title="",super.key});

  @override
  State<ImageCropPage> createState() => _ImageCropPageState();
}

class _ImageCropPageState extends State<ImageCropPage> {
  Load load=Load.finish;
  //final _controller = CropController();
  //CropStatus? cropStatus;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: widget.title,
        actions: [
          /*TextButton(
              onPressed: () {
                if(load==Load.loading)return;
                if (cropStatus != null && cropStatus == CropStatus.ready) {
                  setState(() {
                    load=Load.loading;
                  });
                  _controller.crop();
                }
              },
              child: Text(
                S.of(context).g_key_t_1,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(32.0),
                ),
              ))
          */
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child:ProImageEditor.memory(
              widget.imageData,
              callbacks: ProImageEditorCallbacks(
                onImageEditingComplete: (Uint8List bytes) async {
                  setState(() {
                    load=Load.finish;
                  });
                  if (mounted) {
                    Navigator.pop(context, bytes);
                  }
                },
              ),
            ),
            /*Crop(
              image: widget.imageData,
              controller: _controller,
              onCropped: (value) {
                setState(() {
                  load=Load.finish;
                });
                Uint8List _croppedData;
                switch (value) {
                  case CropResult.success(:final croppedImage):
                    _croppedData = croppedImage;
                    break;
                  case CropResult.error(:final error):
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Error'),
                        content:
                        Text('Failed to crop image: ${cause}'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context),
                              child: Text('OK')),
                        ],
                      ),
                    );
                }
                if (mounted) {
                  Navigator.pop(context, croppedImage);
                }
              },
              onStatusChanged: (status) => setState(() {
                cropStatus = status;
              }),
            ),*/
          ),
          Positioned.fill(
            child: Visibility(
              visible: load==Load.loading,
              child: LoadingPage(),
            ),
          ),
        ],
      ),

    );
  }
}
