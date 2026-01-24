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
-keep class com.regula.** { *; }
-dontwarn com.regula.**

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
