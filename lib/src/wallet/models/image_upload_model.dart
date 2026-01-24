import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart' as i_picker;
class ImageUploadModel{
  String? imgType;//原图的图片类型git png等
  i_picker.XFile? imageFile;
  File? imgFile;
  double imgCount=0.0;//图片上传进度
  double imgTotal=0.0;//图片上传进度
  Uint8List? imgMini;
}
