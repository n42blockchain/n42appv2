# N42 Wallet ProGuard Rules
#
# 这些规则用于保护敏感代码不被逆向，同时确保应用正常运行

# ==================== Flutter 基础规则 ====================
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# ==================== Kotlin 规则 ====================
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# ==================== TrustWallet Core ====================
# 保持钱包核心类不被混淆
-keep class wallet.core.jni.** { *; }
-keep class wallet.core.** { *; }
-keepclassmembers class wallet.core.jni.** { *; }

# ==================== 加密相关 ====================
# 保持加密库类
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# ==================== Web3 相关 ====================
-keep class org.web3j.** { *; }
-dontwarn org.web3j.**

# ==================== OkHttp ====================
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ==================== Gson / JSON ====================
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# ==================== Firebase ====================
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ==================== 自定义 AAR 库 ====================
# mobile-sdk-android.aar

# evm.aar
-keep class ai.n42.evm.** { *; }
-dontwarn ai.n42.evm.**

# ==================== 安全设置 ====================
# 移除日志
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# 保护反射相关
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ==================== 枚举 ====================
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ==================== Parcelable ====================
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# ==================== Serializable ====================
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ==================== Native 方法 ====================
-keepclasseswithmembernames class * {
    native <methods>;
}

# ==================== 注解 ====================
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations

# ==================== 优化选项 ====================
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# ==================== 防止崩溃 ====================
# 保持 MethodChannel 相关类
-keep class io.flutter.plugin.common.** { *; }

# ==================== JNA (Java Native Access) ====================
# yttrium WalletConnect SDK 通过 JNA 调用 Rust FFI，必须保留所有字段和方法
-keep class com.sun.jna.** { *; }
-keepclassmembers class com.sun.jna.** { *; }
-dontwarn com.sun.jna.**

# ==================== UniFFI / yttrium WalletConnect Pay ====================
-keep class uniffi.** { *; }
-keepclassmembers class uniffi.** { *; }
-dontwarn uniffi.**

# ==================== QR Code Scanner (qr_code_scanner_plus / ZXing) ====================
-keep class com.journeyapps.barcodescanner.** { *; }
-keep class com.google.zxing.** { *; }
-dontwarn com.journeyapps.barcodescanner.**
-dontwarn com.google.zxing.**

# ==================== Mobile Scanner (mobile_scanner / CameraX + ML Kit) ====================
-keep class dev.steenbakker.mobile_scanner.** { *; }
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.android.gms.vision.**

# MediaPipe (transitive dep of ML Kit face/vision plugins) — proto classes
# stripped from the runtime jar, only referenced by unused profiler/template code paths
-dontwarn com.google.mediapipe.proto.CalculatorProfileProto$CalculatorProfile
-dontwarn com.google.mediapipe.proto.GraphTemplateProto$CalculatorGraphTemplate

# ==================== Google Play Core ====================
# 抑制 Play Core 分发功能的警告
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# javax.lang.model classes referenced by auto-value/javapoet at compile time only
-dontwarn javax.lang.model.SourceVersion
-dontwarn javax.lang.model.element.Element
-dontwarn javax.lang.model.element.ElementKind
-dontwarn javax.lang.model.type.TypeMirror
-dontwarn javax.lang.model.type.TypeVisitor
-dontwarn javax.lang.model.util.SimpleTypeVisitor8
