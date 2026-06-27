# 虚拟背景 · 发布轨道帧注入（技术设计 + Codex 任务）

> 状态：**设计 + 参考实现，待原生落地**。本机（Windows）无法编译 Android/iOS
> 原生，且本特性 gated 在 flutter_webrtc 改造上（见「核心障碍」）——故以设计文档
> 形式交付，由 Codex 在 Mac/带 NDK 环境实现 + 验证。
> 发布方：Windows 端 Claude Code。日期：2026-06-27。

## 1. 现状（已真实落地的部分）

- **Dart 合成引擎真实可用且已单测**：`packages/n42_chat/lib/src/services/voip/
  virtual_background_processor.dart` 的 `VirtualBackgroundEngine.composeFrame`
  跑 ML Kit 人像分割（`google_mlkit_selfie_segmentation`）→ 置信度 mask →
  Isolate alpha 合成（模糊/纯色/虚拟背景图）。6 个单测验证前景保留/三种背景替换/
  小帧半径夹紧（`test/unit/services/virtual_background_engine_test.dart`）。
- **本地自视图可用**：`VoipCameraProcessor.renderFrame(frameBytes)` 直接产出合成帧
  供本地预览。
- **原生配置通道已就位**：`VoipCameraProcessor.pushConfigToNative()` 经
  `MethodChannel('n42.chat/virtual_background')` 下发：
  - `setBackgroundConfig` → `{mode, blurRadius, solidColor, hasBackgroundImage}`
    （`mode` ∈ `none|blur|virtualBackground|solidColor`）。在 `init`/`restart`/
    `LiveKitService._updateBackgroundProcessing` 时调用。
  - `clearBackground` → `destroy` 时调用。
  原生未实现时经 `MissingPluginException` 优雅 no-op（发布轨道透传）。

**缺口**：发布给对端的 WebRTC 轨道仍是**原始摄像头帧**——对端看不到虚拟背景。
本特性即补这一段：在原生侧把合成帧写回发布轨道。

## 2. 核心障碍（为何不能纯 Dart / 简单原生解决）

链路是 `livekit_client(Dart)` → `flutter_webrtc(Dart)` → `libwebrtc(native)`。
真正能改帧的是 libwebrtc 的 `VideoProcessor`（Android）/ frame processor（iOS），
但：

1. **flutter_webrtc 不向 app 暴露底层 `org.webrtc.VideoSource`/`VideoTrack`**。
   它把本地轨道存在插件内部的 `LocalTrack` 注册表里，按 trackId 索引，无公开 API
   取出来挂 `VideoProcessor`。
2. **livekit_client 又在 flutter_webrtc 之上再包一层**，`LocalVideoTrack` 的原生
   句柄同样不暴露。
3. `livekit_client` 的 Dart `TrackProcessor.processedTrack` 必须返回一个
   `MediaStreamTrack`，但 Dart 侧拿不到摄像头逐帧数据，无法在 Dart 合成后重新
   编码成轨道（这就是当前 `processedTrack` 透传的原因）。

**结论**：必须改 native 管线。三条路：

| 方案 | 做法 | 评价 |
|---|---|---|
| **A. fork flutter_webrtc 暴露 VideoProcessor**（推荐） | path-override flutter_webrtc，在其 Android `LocalVideoTrack`/`GetUserMediaImpl` 上加 `setVideoProcessor(trackId, processor)` 公开 API；iOS 同理在 capturer delegate 处加 hook | 改动可控、对齐上游 `VideoProcessor` 概念；缺点是维护 fork |
| **B. 自建视频源** | 用 CameraX(Android)/AVFoundation(iOS) 自采集→ML Kit 合成→推进自建 `VideoSource`→把该轨道发布给 LiveKit | 绕开 flutter_webrtc 内部，但需 LiveKit 的 `PeerConnectionFactory`（同样不暴露），且与 LiveKit 摄像头管理冲突 |
| **C. 等上游** | 等 livekit/flutter_webrtc 官方 frame processor | 不可控 |

**推荐 A**。下文给 A 的参考实现。

## 3. 参考实现（方案 A）

### 3.1 依赖

`android/app/build.gradle`：
```gradle
implementation 'com.google.mlkit:segmentation-selfie:16.0.0-beta6'
// org.webrtc 经 flutter_webrtc 传递依赖，无需显式声明
```

### 3.2 flutter_webrtc fork：暴露 VideoProcessor 注册

`pubspec.yaml` 加 path override 指向 fork（或 git fork）。在 fork 的 Android
`FlutterWebRTCPlugin`/`GetUserMediaImpl` 增加：
```kotlin
// 按 trackId 找到本地 VideoTrack 的 VideoSource，挂处理器
fun setVideoProcessor(trackId: String, processor: VideoProcessor?) {
    val track = localTracks[trackId]?.track as? VideoTrack ?: return
    // VideoSource 在创建本地轨道时持有；fork 里把它存进 LocalTrack 以便此处取用
    videoSourceForTrack[trackId]?.setVideoProcessor(processor)
}
```
> ⚠️ flutter_webrtc 当前没有把 `VideoSource` 与 trackId 关联存起来——fork 的主要
> 工作是在 `getUserMedia` 创建摄像头轨道时把 `VideoSource` 记进 `LocalTrack`。

### 3.3 Android VideoProcessor（ML Kit 分割 + 合成）

`android/app/src/main/kotlin/ai/n42/www/VirtualBackgroundProcessor.kt`（参考骨架，
**Codex 需编译/验证**）：
```kotlin
class N42VirtualBackgroundProcessor : org.webrtc.VideoProcessor {
    @Volatile var mode: String = "none"      // none|blur|virtualBackground|solidColor
    @Volatile var blurRadius: Float = 0.5f
    @Volatile var backgroundBitmap: Bitmap? = null
    private var sink: VideoSink? = null
    private val segmenter = Segmentation.getClient(
        SelfieSegmenterOptions.Builder()
            .setDetectorMode(SelfieSegmenterOptions.STREAM_MODE)
            .build())

    override fun setSink(sink: VideoSink?) { this.sink = sink }
    override fun onCapturerStarted(success: Boolean) {}
    override fun onCapturerStopped() {}

    override fun onFrameCaptured(frame: VideoFrame) {
        if (mode == "none") { sink?.onFrame(frame); return }
        // 1) VideoFrame(I420) → Bitmap（YuvHelper / YuvConverter）
        // 2) InputImage.fromBitmap → segmenter.process → SegmentationMask
        // 3) 按 mask 合成（前景原图、背景模糊/纯色/bitmap），同 Dart composeFrame 逻辑
        // 4) Bitmap → I420 VideoFrame.Buffer，构造新 VideoFrame（保留 timestamp/rotation）
        // 5) sink?.onFrame(newFrame)
        // ML Kit 是异步：用最近一帧 mask 做合成（帧率自适应，丢 mask 不丢帧），
        // 避免阻塞 capturer 线程。失败则原样 sink?.onFrame(frame) 降级。
    }
}
```
合成算法与 Dart 端 `VirtualBackgroundEngine._composeInIsolate` 一致（前景置信度
阈值 0.5、模糊半径按帧尺寸夹紧、虚拟背景图 cover 铺满），可对照移植。

### 3.4 通道处理器（接住 Dart 已下发的配置）

`VirtualBackgroundHandler.kt`：注册 `n42.chat/virtual_background`，处理
`setBackgroundConfig`/`clearBackground`，更新 `N42VirtualBackgroundProcessor` 的
字段，并在通话本地视频轨道就绪时调用 fork 的 `setVideoProcessor(trackId, proc)`。
trackId 需从 LiveKit 本地视频轨道取（livekit_client Dart `LocalVideoTrack.sid`/
底层 mediaStreamTrack id；可由 Dart 侧随 `setBackgroundConfig` 一并下发 trackId）。
> 建议：扩展 Dart `pushConfigToNative` 多带一个 `trackId`（本地相机轨道的
> `mediaStreamTrack.id`），原生据此定位 VideoSource。

`MainActivity.configureFlutterEngine` 注册：`VirtualBackgroundHandler.register(flutterEngine, this)`。

### 3.5 iOS（方案 A 对应）

flutter_webrtc iOS 在 `LocalVideoTrack`/`RTCCameraVideoCapturer` 的
`captureOutput` delegate 处取 `CMSampleBuffer`；fork 暴露一个 frame processor 注册
点。处理：`CMSampleBuffer`→`CVPixelBuffer`→Vision/ML Kit 分割→Core Image 合成→
回填 `CVPixelBuffer`→`RTCVideoFrame`→送回 source。同样需 fork 把 capturer 的
delegate 链路开放给 app 注入处理器。

## 4. Codex 任务 T7（验收）

1. fork flutter_webrtc（path/git override），暴露按 trackId 的 VideoProcessor 注册
   （Android 先行；iOS 后续）。`flutter pub get` + Android build 通过。
2. 实现 `N42VirtualBackgroundProcessor`（§3.3）+ `VirtualBackgroundHandler`（§3.4），
   加 ML Kit 依赖，`MainActivity` 注册。Android `flutter build apk --debug` 通过。
3. Dart 侧 `pushConfigToNative` 增带本地相机 `trackId`（小改
   `virtual_background_processor.dart` + 同步 vendored）。
4. 真机验证：A 拨通视频通话并开启"虚拟背景/背景模糊"，**B 端**看到 A 的背景被
   替换/模糊（不只本地预览）；切回 `none` 恢复原始背景；通话性能可接受（≤15fps
   处理，掉 mask 不掉帧）。报告 `docs/device-test-reports/<日期>-virtual-bg.md`。
5. iOS 同等实现（§3.5），可作为 T7 的第二阶段。

> 基线 `master`。Dart 合成引擎/单测/配置通道已就位（见 §1），原生接好即对发布帧
> 生效。**不要改 Dart 合成算法**（已测）；如需对照，移植 `composeFrame` 的逻辑到
> Kotlin/Swift 即可。
