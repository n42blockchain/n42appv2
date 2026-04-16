import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;

/// 测试图片上传功能
/// 
/// 运行测试: flutter test test/unit/image_upload_test.dart
void main() {
  group('MatrixFile 测试', () {
    test('MatrixImageFile 创建测试', () {
      // 创建一个简单的测试图片字节数据 (1x1 红色 PNG)
      final pngBytes = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG 签名
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 像素
        0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
        0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41,
        0x54, 0x08, 0xD7, 0x63, 0xF8, 0x0F, 0x00, 0x00,
        0x01, 0x01, 0x00, 0x05, 0x18, 0xD8, 0x4D, 0x00,
        0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
        0x42, 0x60, 0x82,
      ]);
      
      // 创建 MatrixImageFile
      final imageFile = matrix.MatrixImageFile(
        bytes: pngBytes,
        name: 'test_image.png',
        mimeType: 'image/png',
      );
      
      // 验证属性
      expect(imageFile.bytes, isNotNull);
      expect(imageFile.bytes.length, greaterThan(0));
      expect(imageFile.name, equals('test_image.png'));
      expect(imageFile.mimeType, equals('image/png'));
      
      print('✅ MatrixImageFile 创建成功');
      print('   - 文件名: ${imageFile.name}');
      print('   - MIME 类型: ${imageFile.mimeType}');
      print('   - 字节大小: ${imageFile.bytes.length}');
    });
    
    test('MatrixAudioFile 创建测试', () {
      // 创建测试音频字节数据
      final audioBytes = Uint8List.fromList(List.generate(1000, (i) => i % 256));
      
      // 创建 MatrixAudioFile
      final audioFile = matrix.MatrixAudioFile(
        bytes: audioBytes,
        name: 'test_audio.m4a',
        mimeType: 'audio/mp4',
        duration: 5000, // 5秒
      );
      
      // 验证属性
      expect(audioFile.bytes, isNotNull);
      expect(audioFile.name, equals('test_audio.m4a'));
      expect(audioFile.mimeType, equals('audio/mp4'));
      
      print('✅ MatrixAudioFile 创建成功');
      print('   - 文件名: ${audioFile.name}');
      print('   - MIME 类型: ${audioFile.mimeType}');
      print('   - 字节大小: ${audioFile.bytes.length}');
    });
    
    test('MatrixVideoFile 创建测试', () {
      // 创建测试视频字节数据
      final videoBytes = Uint8List.fromList(List.generate(5000, (i) => i % 256));
      
      // 创建 MatrixVideoFile
      final videoFile = matrix.MatrixVideoFile(
        bytes: videoBytes,
        name: 'test_video.mp4',
        mimeType: 'video/mp4',
      );
      
      // 验证属性
      expect(videoFile.bytes, isNotNull);
      expect(videoFile.name, equals('test_video.mp4'));
      expect(videoFile.mimeType, equals('video/mp4'));
      
      print('✅ MatrixVideoFile 创建成功');
      print('   - 文件名: ${videoFile.name}');
      print('   - MIME 类型: ${videoFile.mimeType}');
      print('   - 字节大小: ${videoFile.bytes.length}');
    });
    
    test('MatrixFile 创建测试', () {
      // 创建测试文件字节数据
      final fileBytes = Uint8List.fromList(List.generate(2000, (i) => i % 256));
      
      // 创建 MatrixFile
      final file = matrix.MatrixFile(
        bytes: fileBytes,
        name: 'test_file.pdf',
        mimeType: 'application/pdf',
      );
      
      // 验证属性
      expect(file.bytes, isNotNull);
      expect(file.name, equals('test_file.pdf'));
      expect(file.mimeType, equals('application/pdf'));
      
      print('✅ MatrixFile 创建成功');
      print('   - 文件名: ${file.name}');
      print('   - MIME 类型: ${file.mimeType}');
      print('   - 字节大小: ${file.bytes.length}');
    });
  });
  
  group('MIME 类型检测测试', () {
    test('根据文件扩展名判断 MIME 类型', () {
      final testCases = {
        'image.jpg': 'image/jpeg',
        'image.jpeg': 'image/jpeg',
        'image.png': 'image/png',
        'image.gif': 'image/gif',
        'image.webp': 'image/webp',
        'image.heic': 'image/heic',
        'audio.m4a': 'audio/mp4',
        'audio.mp3': 'audio/mpeg',
        'audio.ogg': 'audio/ogg',
        'video.mp4': 'video/mp4',
        'document.pdf': 'application/pdf',
      };
      
      for (final entry in testCases.entries) {
        final filename = entry.key;
        final expectedMimeType = entry.value;
        final actualMimeType = _getMimeTypeFromFilename(filename);
        
        expect(actualMimeType, equals(expectedMimeType),
            reason: 'MIME type for $filename should be $expectedMimeType');
        print('✅ $filename -> $actualMimeType');
      }
    });
  });
  
  group('文件名处理测试', () {
    test('确保文件名有扩展名', () {
      expect(_ensureExtension('image', '.jpg'), equals('image.jpg'));
      expect(_ensureExtension('image.jpg', '.jpg'), equals('image.jpg'));
      expect(_ensureExtension('IMG_001', '.png'), equals('IMG_001.png'));
      expect(_ensureExtension('', '.jpg'), equals('.jpg'));
      
      print('✅ 文件名扩展名处理正确');
    });
  });
}

/// 根据文件名获取 MIME 类型
String _getMimeTypeFromFilename(String filename) {
  final lowerFilename = filename.toLowerCase();
  
  // 图片
  if (lowerFilename.endsWith('.jpg') || lowerFilename.endsWith('.jpeg')) {
    return 'image/jpeg';
  } else if (lowerFilename.endsWith('.png')) {
    return 'image/png';
  } else if (lowerFilename.endsWith('.gif')) {
    return 'image/gif';
  } else if (lowerFilename.endsWith('.webp')) {
    return 'image/webp';
  } else if (lowerFilename.endsWith('.heic')) {
    return 'image/heic';
  } else if (lowerFilename.endsWith('.heif')) {
    return 'image/heif';
  }
  
  // 音频
  else if (lowerFilename.endsWith('.m4a')) {
    return 'audio/mp4';
  } else if (lowerFilename.endsWith('.mp3')) {
    return 'audio/mpeg';
  } else if (lowerFilename.endsWith('.ogg') || lowerFilename.endsWith('.opus')) {
    return 'audio/ogg';
  } else if (lowerFilename.endsWith('.wav')) {
    return 'audio/wav';
  }
  
  // 视频
  else if (lowerFilename.endsWith('.mp4')) {
    return 'video/mp4';
  } else if (lowerFilename.endsWith('.mov')) {
    return 'video/quicktime';
  }
  
  // 文档
  else if (lowerFilename.endsWith('.pdf')) {
    return 'application/pdf';
  }
  
  return 'application/octet-stream';
}

/// 确保文件名有扩展名
String _ensureExtension(String filename, String defaultExtension) {
  if (filename.contains('.')) {
    return filename;
  }
  return filename + defaultExtension;
}
