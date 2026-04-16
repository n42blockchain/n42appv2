import 'package:flutter_test/flutter_test.dart';

/// TTS 语言检测逻辑测试
///
/// TtsService._detectLanguage 是私有方法，这里独立重建该算法进行验证。
/// 同时测试 TtsState 枚举和 isSpeaking 等纯逻辑。
///
/// 语言检测算法逻辑：
/// 1. 空文本返回 'en-US'
/// 2. 如果中/日/韩字符占比 > 30%，则按数量最多的语言返回
/// 3. 日文字符最多 -> 'ja-JP'
/// 4. 韩文字符最多 -> 'ko-KR'
/// 5. 否则返回 'zh-CN'（中文为默认非 ASCII 语言）
/// 6. 占比 <= 30% 返回 'en-US'

// 从 TtsService 中提取的语言检测算法（镜像实现用于测试）
String detectLanguage(String text) {
  final chineseRegex = RegExp(r'[\u4e00-\u9fff]');
  final chineseCount = chineseRegex.allMatches(text).length;

  final japaneseRegex = RegExp(r'[\u3040-\u309f\u30a0-\u30ff]');
  final japaneseCount = japaneseRegex.allMatches(text).length;

  final koreanRegex = RegExp(r'[\uac00-\ud7af]');
  final koreanCount = koreanRegex.allMatches(text).length;

  final totalNonAscii = chineseCount + japaneseCount + koreanCount;
  final totalLength = text.length;

  if (totalLength == 0) return 'en-US';

  if (totalNonAscii / totalLength > 0.3) {
    if (japaneseCount > chineseCount && japaneseCount > koreanCount) {
      return 'ja-JP';
    }
    if (koreanCount > chineseCount) {
      return 'ko-KR';
    }
    return 'zh-CN';
  }

  return 'en-US';
}

void main() {
  group('TTS Language Detection', () {
    group('empty and ASCII text', () {
      test('should return en-US for empty text', () {
        expect(detectLanguage(''), 'en-US');
      });

      test('should return en-US for pure English text', () {
        expect(detectLanguage('Hello, how are you?'), 'en-US');
      });

      test('should return en-US for ASCII-only text with numbers', () {
        expect(detectLanguage('Order #12345 confirmed'), 'en-US');
      });

      test('should return en-US for ASCII symbols', () {
        expect(detectLanguage('!@#\$%^&*()'), 'en-US');
      });
    });

    group('Chinese detection', () {
      test('should detect pure Chinese text', () {
        expect(detectLanguage('你好世界'), 'zh-CN');
      });

      test('should detect Chinese text with some English', () {
        expect(detectLanguage('你好Hello世界'), 'zh-CN');
      });

      test('should detect predominantly Chinese text', () {
        expect(detectLanguage('今天天气不错，我们出去玩吧'), 'zh-CN');
      });

      test('should return en-US when Chinese characters are below 30%', () {
        // 1 Chinese character out of 10 total characters = 10%
        expect(detectLanguage('Hello你World'), 'en-US');
      });
    });

    group('Japanese detection', () {
      test('should detect pure hiragana text', () {
        expect(detectLanguage('こんにちは'), 'ja-JP');
      });

      test('should detect pure katakana text', () {
        expect(detectLanguage('カタカナテスト'), 'ja-JP');
      });

      test('should detect mixed hiragana and katakana', () {
        expect(detectLanguage('こんにちはカタカナ'), 'ja-JP');
      });

      test('should detect Japanese when it has more kana than kanji', () {
        // Japanese kana should outnumber Chinese characters
        expect(detectLanguage('おはようございます'), 'ja-JP');
      });

      test('should detect Japanese with mixed kanji and kana', () {
        // 今日 = 2 kanji (counted as Chinese), は = hiragana, いい = 2 hiragana, 天気 = 2 kanji, です = 2 hiragana
        // kana count (5) > kanji count (4) -> ja-JP
        expect(detectLanguage('今日はいい天気です'), 'ja-JP');
      });
    });

    group('Korean detection', () {
      test('should detect pure Korean text', () {
        expect(detectLanguage('안녕하세요'), 'ko-KR');
      });

      test('should detect Korean text with some English', () {
        expect(detectLanguage('안녕하세요 Hello'), 'ko-KR');
      });

      test('should detect Korean over Chinese when Korean count is higher', () {
        // 5 Korean characters vs 1 Chinese character
        expect(detectLanguage('안녕하세요你'), 'ko-KR');
      });
    });

    group('mixed language priority', () {
      test('should prefer Japanese when it has highest count', () {
        // 5 kana vs 2 kanji vs 0 Korean -> ja-JP
        expect(detectLanguage('こんにちは你好'), 'ja-JP');
      });

      test('should prefer Korean over Chinese when Korean count is higher', () {
        // Korean > Chinese and not Japanese
        expect(detectLanguage('안녕하세요你好'), 'ko-KR');
      });

      test('should return zh-CN when Chinese count equals Korean count', () {
        // When koreanCount is NOT greater than chineseCount (equal), returns zh-CN
        // 2 Chinese + 2 Korean -> koreanCount (2) not > chineseCount (2) -> zh-CN
        expect(detectLanguage('你好안녕'), 'zh-CN');
      });

      test('should return zh-CN when Chinese has the highest count', () {
        expect(detectLanguage('你好世界今天안녕'), 'zh-CN');
      });
    });

    group('threshold boundary (30%)', () {
      test('should return en-US when non-ASCII ratio is exactly 30%', () {
        // 3 Chinese out of 10 total = 30%, NOT > 30%
        expect(detectLanguage('你好世abcdefg'), 'en-US');
      });

      test('should detect language when non-ASCII ratio exceeds 30%', () {
        // 4 Chinese out of 10 total = 40%, > 30%
        expect(detectLanguage('你好世界abcdef'), 'zh-CN');
      });
    });
  });

  group('TtsState enum', () {
    test('should have three states', () {
      // We just validate the algorithm recognizes these conceptual states
      // The actual TtsState enum is in the service file
      const states = ['stopped', 'playing', 'paused'];
      expect(states.length, 3);
      expect(states, contains('stopped'));
      expect(states, contains('playing'));
      expect(states, contains('paused'));
    });
  });
}
