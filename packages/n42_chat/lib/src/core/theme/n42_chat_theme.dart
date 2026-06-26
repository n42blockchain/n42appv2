import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

/// N42 Chat 主题配置
///
/// 支持自定义颜色、字体和尺寸，也提供预设主题
///
/// ## 使用预设主题
///
/// ```dart
/// N42ChatTheme.wechatLight()
/// N42ChatTheme.wechatDark()
/// ```
///
/// ## 自定义主题
///
/// ```dart
/// N42ChatTheme(
///   primaryColor: Colors.blue,
///   backgroundColor: Colors.grey[100]!,
///   // ...
/// )
/// ```
@immutable
class N42ChatTheme {
  // ============================================
  // 颜色配置
  // ============================================

  /// 主色
  final Color primaryColor;

  /// 页面背景色
  final Color backgroundColor;

  /// 卡片/列表项背景色
  final Color surfaceColor;

  /// 导航栏背景色
  final Color navBarColor;

  /// 底部导航栏背景色
  final Color bottomNavBarColor;

  /// 分割线颜色
  final Color dividerColor;

  /// 主要文字颜色
  final Color textPrimaryColor;

  /// 次要文字颜色
  final Color textSecondaryColor;

  /// 辅助文字颜色
  final Color textTertiaryColor;

  /// 发送消息气泡颜色
  final Color messageBubbleSentColor;

  /// 接收消息气泡颜色
  final Color messageBubbleReceivedColor;

  /// 发送消息文字颜色
  final Color messageTextSentColor;

  /// 接收消息文字颜色
  final Color messageTextReceivedColor;

  /// 徽章颜色
  final Color badgeColor;

  /// 输入框背景色
  final Color inputBackgroundColor;

  // ============================================
  // 尺寸配置
  // ============================================

  /// 头像圆角半径
  final double avatarRadius;

  /// 消息气泡圆角半径
  final double messageBubbleRadius;

  /// 卡片圆角半径
  final double cardRadius;

  /// 按钮圆角半径
  final double buttonRadius;

  /// 列表项高度
  final double listItemHeight;

  /// 头像大小
  final double avatarSize;

  /// 小头像大小
  final double avatarSizeSmall;

  /// 导航栏高度
  final double appBarHeight;

  // ============================================
  // 文字样式配置
  // ============================================

  /// 标题文字样式
  final TextStyle? titleTextStyle;

  /// 正文文字样式
  final TextStyle? bodyTextStyle;

  /// 辅助文字样式
  final TextStyle? captionTextStyle;

  /// 按钮文字样式
  final TextStyle? buttonTextStyle;

  // ============================================
  // 亮度
  // ============================================

  /// 是否为深色模式
  final bool isDark;

  const N42ChatTheme({
    required this.primaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.navBarColor,
    required this.bottomNavBarColor,
    required this.dividerColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.textTertiaryColor,
    required this.messageBubbleSentColor,
    required this.messageBubbleReceivedColor,
    required this.messageTextSentColor,
    required this.messageTextReceivedColor,
    required this.badgeColor,
    required this.inputBackgroundColor,
    this.avatarRadius = 4.0,
    this.messageBubbleRadius = 4.0,
    this.cardRadius = 8.0,
    this.buttonRadius = 4.0,
    this.listItemHeight = 64.0,
    this.avatarSize = 48.0,
    this.avatarSizeSmall = 40.0,
    this.appBarHeight = 44.0,
    this.titleTextStyle,
    this.bodyTextStyle,
    this.captionTextStyle,
    this.buttonTextStyle,
    this.isDark = false,
  });

  /// 微信浅色主题
  factory N42ChatTheme.wechatLight() => const N42ChatTheme(
        primaryColor: AppColors.primary,
        backgroundColor: AppColors.background,
        surfaceColor: AppColors.surface,
        navBarColor: AppColors.navBar,
        bottomNavBarColor: AppColors.bottomNavBar,
        dividerColor: AppColors.divider,
        textPrimaryColor: AppColors.textPrimary,
        textSecondaryColor: AppColors.textSecondary,
        textTertiaryColor: AppColors.textTertiary,
        messageBubbleSentColor: AppColors.bubbleSelf,
        messageBubbleReceivedColor: AppColors.bubbleOther,
        messageTextSentColor: AppColors.messageTextSent,
        messageTextReceivedColor: AppColors.messageTextReceived,
        badgeColor: AppColors.badge,
        inputBackgroundColor: AppColors.inputBackground,
        isDark: false,
      );

  /// 微信深色主题
  factory N42ChatTheme.wechatDark() => const N42ChatTheme(
        primaryColor: AppColors.primary,
        backgroundColor: AppColors.backgroundDark,
        surfaceColor: AppColors.surfaceDark,
        navBarColor: AppColors.navBarDark,
        bottomNavBarColor: AppColors.bottomNavBarDark,
        dividerColor: AppColors.dividerDark,
        textPrimaryColor: AppColors.textPrimaryDark,
        textSecondaryColor: AppColors.textSecondaryDark,
        textTertiaryColor: AppColors.textTertiaryDark,
        messageBubbleSentColor: AppColors.bubbleSelfDark,
        messageBubbleReceivedColor: AppColors.bubbleOtherDark,
        messageTextSentColor: AppColors.messageTextSent,
        messageTextReceivedColor: AppColors.messageTextReceivedDark,
        badgeColor: AppColors.badge,
        inputBackgroundColor: AppColors.surfaceDark,
        isDark: true,
      );

  /// 从Material主题生成
  factory N42ChatTheme.fromMaterialTheme(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return N42ChatTheme(
      primaryColor: theme.primaryColor,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceColor: theme.cardColor,
      navBarColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
      bottomNavBarColor: theme.bottomNavigationBarTheme.backgroundColor ??
          theme.scaffoldBackgroundColor,
      dividerColor: theme.dividerColor,
      textPrimaryColor:
          theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary,
      textSecondaryColor:
          theme.textTheme.bodySmall?.color ?? AppColors.textSecondary,
      textTertiaryColor: AppColors.textTertiary,
      // 气泡固定走微信绿专用色,不随品牌主色(靛蓝)漂移
      messageBubbleSentColor:
          isDark ? AppColors.bubbleSelfDark : AppColors.bubbleSelf,
      messageBubbleReceivedColor: theme.cardColor,
      messageTextSentColor: isDark ? Colors.white : AppColors.messageTextSent,
      messageTextReceivedColor:
          isDark ? Colors.white : AppColors.messageTextReceived,
      badgeColor: theme.colorScheme.error,
      inputBackgroundColor: isDark ? theme.cardColor : AppColors.inputBackground,
      isDark: isDark,
    );
  }

  /// 转换为Flutter ThemeData
  ThemeData toThemeData() {
    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: isDark
          ? primaryColor.withValues(alpha: 0.18)
          : primaryColor.withValues(alpha: 0.10),
      onPrimaryContainer: primaryColor,
      secondary: primaryColor,
      onSecondary: Colors.white,
      secondaryContainer: isDark
          ? primaryColor.withValues(alpha: 0.18)
          : primaryColor.withValues(alpha: 0.10),
      onSecondaryContainer: primaryColor,
      error: AppColors.error,
      onError: Colors.white,
      surface: surfaceColor,
      onSurface: textPrimaryColor,
      surfaceContainerHighest: isDark
          ? AppColors.surfaceDark
          : AppColors.inputBackground,
      outline: dividerColor,
      outlineVariant: isDark ? AppColors.dividerThinDark : AppColors.dividerThin,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
      borderSide: BorderSide.none,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dividerColor: dividerColor,
      colorScheme: colorScheme,

      // iOS-style page transitions for WeChat-like horizontal slide-back
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: navBarColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: titleTextStyle ??
            AppTextStyles.headlineSmall.copyWith(color: textPrimaryColor),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bottomNavBarColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.captionSmall.copyWith(
          color: primaryColor,
        ),
        unselectedLabelStyle: AppTextStyles.captionSmall.copyWith(
          color: textSecondaryColor,
        ),
      ),

      textTheme: TextTheme(
        headlineLarge:
            AppTextStyles.headlineLarge.copyWith(color: textPrimaryColor),
        headlineMedium:
            AppTextStyles.headlineMedium.copyWith(color: textPrimaryColor),
        headlineSmall:
            AppTextStyles.headlineSmall.copyWith(color: textPrimaryColor),
        titleLarge:
            AppTextStyles.headlineSmall.copyWith(color: textPrimaryColor),
        titleMedium:
            AppTextStyles.bodyLarge.medium.copyWith(color: textPrimaryColor),
        titleSmall:
            AppTextStyles.bodyMedium.medium.copyWith(color: textPrimaryColor),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textPrimaryColor),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: textPrimaryColor),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: textSecondaryColor),
        labelLarge: AppTextStyles.buttonPrimary,
        labelMedium:
            AppTextStyles.caption.copyWith(color: textSecondaryColor),
        labelSmall:
            AppTextStyles.captionSmall.copyWith(color: textTertiaryColor),
      ),

      // 主按钮（实心绿）
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark
              ? AppColors.textDisabledDark
              : AppColors.textDisabled,
          disabledForegroundColor: Colors.white,
          textStyle: AppTextStyles.buttonPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
        ),
      ),

      // 次要按钮（描边绿）
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: AppTextStyles.buttonSecondary,
          side: BorderSide(color: primaryColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          minimumSize: const Size(0, 48),
        ),
      ),

      // 文字按钮——杜绝 Material 3 默认紫色
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // IconButton——继承前景色（默认前景色由 IconTheme 给）
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textPrimaryColor,
        ),
      ),

      iconTheme: IconThemeData(color: textPrimaryColor, size: 24),
      primaryIconTheme: const IconThemeData(color: Colors.white, size: 24),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackgroundColor,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.inputHint,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: textSecondaryColor),
        errorStyle: AppTextStyles.errorText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        isDense: true,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.listItemPadding,
        ),
        minVerticalPadding: 12,
        tileColor: surfaceColor,
        iconColor: textSecondaryColor,
        textColor: textPrimaryColor,
      ),

      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: AppDimensions.dividerThickness,
        space: 0,
      ),

      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: AppDimensions.cardElevation,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: AppDimensions.overlayElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
        ),
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: textPrimaryColor,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: textPrimaryColor,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        modalBackgroundColor: surfaceColor,
        elevation: AppDimensions.overlayElevation,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.dialogRadius),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: textTertiaryColor,
      ),

      // Switch / Checkbox / Radio——杜绝 Material 3 默认紫
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return null;
          return states.contains(WidgetState.selected)
              ? Colors.white
              : (isDark ? AppColors.textTertiaryDark : Colors.white);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return isDark ? AppColors.dividerDark : AppColors.divider;
          }
          return states.contains(WidgetState.selected)
              ? primaryColor
              : (isDark ? AppColors.dividerDark : AppColors.divider);
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return isDark
                ? AppColors.textDisabledDark
                : AppColors.textDisabled;
          }
          return states.contains(WidgetState.selected)
              ? primaryColor
              : Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: BorderSide(color: textTertiaryColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return textTertiaryColor;
        }),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: dividerColor,
        circularTrackColor: dividerColor,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.inputBackground,
        selectedColor: primaryColor.withValues(alpha: 0.15),
        secondarySelectedColor: primaryColor.withValues(alpha: 0.15),
        disabledColor: dividerColor,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: textPrimaryColor),
        secondaryLabelStyle: AppTextStyles.bodySmall.copyWith(
          color: primaryColor,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: textSecondaryColor,
        labelStyle: AppTextStyles.bodyMedium.medium,
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: AppDimensions.overlayElevation,
        shape: const CircleBorder(),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : Colors.black.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // SnackBar 浮起、靠近底部、横滑取消
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.surface : AppColors.surfaceDark,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textPrimary : Colors.white,
        ),
        actionTextColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        dismissDirection: DismissDirection.horizontal,
      ),

      splashFactory: InkSparkle.splashFactory,
    );
  }

  /// 复制并修改
  N42ChatTheme copyWith({
    Color? primaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? navBarColor,
    Color? bottomNavBarColor,
    Color? dividerColor,
    Color? textPrimaryColor,
    Color? textSecondaryColor,
    Color? textTertiaryColor,
    Color? messageBubbleSentColor,
    Color? messageBubbleReceivedColor,
    Color? messageTextSentColor,
    Color? messageTextReceivedColor,
    Color? badgeColor,
    Color? inputBackgroundColor,
    double? avatarRadius,
    double? messageBubbleRadius,
    double? cardRadius,
    double? buttonRadius,
    double? listItemHeight,
    double? avatarSize,
    double? avatarSizeSmall,
    double? appBarHeight,
    TextStyle? titleTextStyle,
    TextStyle? bodyTextStyle,
    TextStyle? captionTextStyle,
    TextStyle? buttonTextStyle,
    bool? isDark,
  }) {
    return N42ChatTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      navBarColor: navBarColor ?? this.navBarColor,
      bottomNavBarColor: bottomNavBarColor ?? this.bottomNavBarColor,
      dividerColor: dividerColor ?? this.dividerColor,
      textPrimaryColor: textPrimaryColor ?? this.textPrimaryColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
      textTertiaryColor: textTertiaryColor ?? this.textTertiaryColor,
      messageBubbleSentColor:
          messageBubbleSentColor ?? this.messageBubbleSentColor,
      messageBubbleReceivedColor:
          messageBubbleReceivedColor ?? this.messageBubbleReceivedColor,
      messageTextSentColor: messageTextSentColor ?? this.messageTextSentColor,
      messageTextReceivedColor:
          messageTextReceivedColor ?? this.messageTextReceivedColor,
      badgeColor: badgeColor ?? this.badgeColor,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      avatarRadius: avatarRadius ?? this.avatarRadius,
      messageBubbleRadius: messageBubbleRadius ?? this.messageBubbleRadius,
      cardRadius: cardRadius ?? this.cardRadius,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      listItemHeight: listItemHeight ?? this.listItemHeight,
      avatarSize: avatarSize ?? this.avatarSize,
      avatarSizeSmall: avatarSizeSmall ?? this.avatarSizeSmall,
      appBarHeight: appBarHeight ?? this.appBarHeight,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      bodyTextStyle: bodyTextStyle ?? this.bodyTextStyle,
      captionTextStyle: captionTextStyle ?? this.captionTextStyle,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      isDark: isDark ?? this.isDark,
    );
  }
}

