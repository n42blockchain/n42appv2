import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/local_llm_service.dart';

/// 可控的假后端：驱动 LocalLlmService 状态机而不触碰 flutter_gemma 原生。
class _FakeBackend implements LocalLlmBackend {
  _FakeBackend({
    this.capable = false,
    this.downloaded = false,
    this.downloadSucceeds = true,
    this.response = 'hello from device',
  });

  bool capable;
  bool downloaded;
  bool downloadSucceeds;
  String? response;

  int generateCalls = 0;
  String? lastPrompt;
  LocalLlmConfig _config = const LocalLlmConfig();

  @override
  LocalLlmConfig get config => _config;

  @override
  void configure(LocalLlmConfig config) => _config = config;

  @override
  Future<bool> isDeviceCapable() async => capable;

  @override
  Future<bool> isModelDownloaded() async => downloaded;

  @override
  Future<bool> downloadModel({void Function(double progress)? onProgress}) async {
    onProgress?.call(0.5);
    onProgress?.call(1.0);
    if (downloadSucceeds) downloaded = true;
    return downloadSucceeds;
  }

  @override
  Future<bool> loadModel() async => true;

  @override
  Future<void> unloadModel() async {}

  @override
  Future<String?> generate(String prompt, {int maxTokens = 512}) async {
    generateCalls++;
    lastPrompt = prompt;
    return response;
  }
}

void main() {
  group('LocalLlmConfig', () {
    test('hasModelSource 判定', () {
      expect(const LocalLlmConfig().hasModelSource, isFalse);
      expect(const LocalLlmConfig(modelUrl: '   ').hasModelSource, isFalse);
      expect(
        const LocalLlmConfig(modelUrl: 'https://x/m.task').hasModelSource,
        isTrue,
      );
    });

    test('modelFilename 从 URL 末段推导（含 query）', () {
      expect(
        const LocalLlmConfig(modelUrl: 'https://h/gemma3-1b-it.task')
            .modelFilename,
        'gemma3-1b-it.task',
      );
      expect(
        const LocalLlmConfig(
          modelUrl: 'https://h/a/b/model.task?download=true&x=1',
        ).modelFilename,
        'model.task',
      );
      expect(const LocalLlmConfig().modelFilename, '');
    });

    test('copyWith 覆盖字段', () {
      const base = LocalLlmConfig(modelUrl: 'u', maxTokens: 1024);
      final c = base.copyWith(maxTokens: 2048, huggingFaceToken: 'hf');
      expect(c.modelUrl, 'u');
      expect(c.maxTokens, 2048);
      expect(c.huggingFaceToken, 'hf');
    });
  });

  group('LocalLlmService 状态机', () {
    test('设备不支持 → unavailable，generate 返回 null', () async {
      final svc = LocalLlmService(_FakeBackend(capable: false));
      await svc.init();
      expect(svc.state, LocalLlmState.unavailable);
      expect(svc.isReady, isFalse);
      expect(await svc.generate('hi'), isNull);
    });

    test('支持但未下载 → notDownloaded', () async {
      final svc = LocalLlmService(_FakeBackend(capable: true, downloaded: false));
      await svc.init();
      expect(svc.state, LocalLlmState.notDownloaded);
    });

    test('支持且已下载 → ready', () async {
      final svc = LocalLlmService(_FakeBackend(capable: true, downloaded: true));
      await svc.init();
      expect(svc.state, LocalLlmState.ready);
    });

    test('download 成功 → ready 且进度推进到 1.0', () async {
      final backend = _FakeBackend(capable: true, downloaded: false);
      final svc = LocalLlmService(backend);
      await svc.init();
      expect(svc.state, LocalLlmState.notDownloaded);
      await svc.download();
      expect(svc.state, LocalLlmState.ready);
      expect(svc.downloadProgress.value, 1.0);
    });

    test('download 失败 → 回到 notDownloaded', () async {
      final backend =
          _FakeBackend(capable: true, downloaded: false, downloadSucceeds: false);
      final svc = LocalLlmService(backend);
      await svc.init();
      await svc.download();
      expect(svc.state, LocalLlmState.notDownloaded);
    });

    test('ready 且 enabled 时 isReady 为真，generate 透传 prompt 给后端', () async {
      final backend = _FakeBackend(
        capable: true,
        downloaded: true,
        response: 'device says hi',
      );
      final svc = LocalLlmService(backend);
      await svc.init();
      expect(svc.isReady, isFalse); // 默认未启用
      svc.enabled = true;
      expect(svc.isReady, isTrue);
      final out = await svc.generate('summarize this');
      expect(out, 'device says hi');
      expect(backend.generateCalls, 1);
      expect(backend.lastPrompt, 'summarize this');
    });

    test('未 ready 时 generate 不触达后端（直接 null）', () async {
      final backend = _FakeBackend(capable: true, downloaded: false);
      final svc = LocalLlmService(backend)..enabled = true;
      await svc.init(); // notDownloaded
      final out = await svc.generate('x');
      expect(out, isNull);
      expect(backend.generateCalls, 0);
    });

    test('configure 注入模型源后重新探测为 ready', () async {
      final backend = _FakeBackend(capable: false, downloaded: true);
      final svc = LocalLlmService(backend);
      await svc.init();
      expect(svc.state, LocalLlmState.unavailable);
      // 模拟配置后设备变为可用
      backend.capable = true;
      await svc.configure(
        const LocalLlmConfig(modelUrl: 'https://h/m.task'),
      );
      expect(svc.state, LocalLlmState.ready);
      expect(backend.config.modelUrl, 'https://h/m.task');
    });
  });
}
