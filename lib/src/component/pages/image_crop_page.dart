import 'dart:typed_data';

import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/loading_page.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:flutter/material.dart';

class ImageCropPage extends StatefulWidget {
  final Uint8List imageData;
  final String title;
  const ImageCropPage(this.imageData,{this.title="",super.key});

  @override
  State<ImageCropPage> createState() => _ImageCropPageState();
}

class _ImageCropPageState extends State<ImageCropPage> {
  Load load=Load.finish;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: widget.title,
        actions: [],
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
