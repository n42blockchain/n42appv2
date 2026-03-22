import 'dart:typed_data';

import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:flutter/material.dart';

class ImageCropPage extends StatelessWidget {
  final Uint8List imageData;
  final String title;
  const ImageCropPage(this.imageData,{this.title="",super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: title,
        actions: [],
      ),
      body: ProImageEditor.memory(
        imageData,
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (Uint8List bytes) async {
            if (context.mounted) {
              Navigator.pop(context, bytes);
            }
          },
        ),
      ),
    );
  }
}
