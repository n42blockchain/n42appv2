part of '../../n42_chat.dart';

/// N42 Chat 入口Widget
///
/// 根据登录状态自动切换页面：
/// - 检查中：显示加载页
/// - 已登录：显示会话列表
/// - 未登录：显示欢迎页面
class _N42ChatEntryWidget extends StatefulWidget {
  const _N42ChatEntryWidget();

  @override
  State<_N42ChatEntryWidget> createState() => _N42ChatEntryWidgetState();
}

class _N42ChatEntryWidgetState extends State<_N42ChatEntryWidget> {
  Locale _currentLocale = _N42ThemeManager._locale;
  FontSize _fontSize = N42Chat.fontSize;

  // 嵌套 Navigator：承载 chat 内部所有 push 的子页面，使其留在
  // _wrapChatPresentation 的 Theme + textScaler 缩放层之下（否则会逃到
  // 宿主根 Navigator 而丢失字体缩放与主题）。
  final GlobalKey<NavigatorState> _nestedNavKey = GlobalKey<NavigatorState>();
  final HeroController _heroController = HeroController();

  void _onLocaleChanged(Locale locale) {
    if (mounted) setState(() => _currentLocale = locale);
  }

  void _onThemeChanged(ThemeMode _) {
    if (mounted) setState(() {});
  }

  void _onFontSizeChanged(FontSize fontSize) {
    if (mounted) setState(() => _fontSize = fontSize);
  }

  Future<void> _loadAppearanceSettings() async {
    try {
      final appearanceSettings = await N42Chat.getSavedAppearanceSettings();
      if (!mounted) return;
      // 宿主接管明暗模式时不要用自存值覆盖宿主下发的 themeMode，
      // 否则每次打开 chat 都会把宿主设置还原。字体大小仍由 chat 自身管理。
      if (!N42Chat.hostControlsAppearance) {
        N42Chat.setThemeMode(appearanceSettings.themeMode);
      }
      N42Chat.setFontSize(appearanceSettings.fontSize);
    } catch (e) {
      debugLog('N42Chat: Failed to load appearance settings: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    N42Chat.addLocaleListener(_onLocaleChanged);
    N42Chat.addThemeListener(_onThemeChanged);
    N42Chat.addFontSizeListener(_onFontSizeChanged);
    unawaited(_loadAppearanceSettings());
    // 检查当前登录状态
    N42Chat.authBloc.add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    N42Chat.removeLocaleListener(_onLocaleChanged);
    N42Chat.removeThemeListener(_onThemeChanged);
    N42Chat.removeFontSizeListener(_onFontSizeChanged);
    _heroController.dispose();
    super.dispose();
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: N42Chat.authBloc,
          child: const LoginPage(),
        ),
      ),
    );
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: N42Chat.authBloc,
          child: const RegisterPage(),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _wrapChatPresentation(
      context,
      locale: _currentLocale,
      fontSize: _fontSize,
      // 嵌套 Navigator：chat 内部所有 push（会话/设置等）都进入本层导航栈，
      // 从而继承上方 _wrapChatPresentation 的 Theme + textScaler，字体缩放
      // 与主题在子页面同样生效。NavigatorPopHandler 把系统返回键优先转交
      // 嵌套栈；当嵌套栈已在根（无可弹）时放行给外层，弹出整个 chat 路由。
      child: NavigatorPopHandler(
        onPopWithResult: (_) => _nestedNavKey.currentState?.maybePop(),
        child: Navigator(
          key: _nestedNavKey,
          observers: [_heroController],
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (context) => BlocProvider.value(
              value: N42Chat.authBloc,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  // 检查中或初始状态 - 显示加载
                  if (state.status == AuthStatus.initial ||
                      state.status == AuthStatus.checking) {
                    return const _LoadingPage();
                  }

                  // 已登录 - 显示主框架（微信风格底部Tab）
                  if (state.isAuthenticated) {
                    return ChatMainPage(
                      onBackToMain: () {
                        N42Chat.requestBackToHost(context);
                      },
                    );
                  }

                  // 未登录 - 显示欢迎页面
                  return WelcomePage(
                    onLogin: () => _navigateToLogin(context),
                    onRegister: () => _navigateToRegister(context),
                    onBack: () => N42Chat.requestBackToHost(context),
                    onTermsOfService: () => _launchUrl(
                      N42Chat._config?.termsOfServiceUrl ??
                          'https://www.n42.ai/static/terms_of_use.html',
                    ),
                    onPrivacyPolicy: () => _launchUrl(
                      N42Chat._config?.privacyPolicyUrl ??
                          'https://www.n42.ai/static/terms_of_use.html',
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 加载页面
class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.bgOf(isDark),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF5B6CFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'N42 Chat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryOf(isDark),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B6CFF)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _N42ChatBootstrapWidget extends StatefulWidget {
  const _N42ChatBootstrapWidget();

  @override
  State<_N42ChatBootstrapWidget> createState() =>
      _N42ChatBootstrapWidgetState();
}

class _N42ChatBootstrapWidgetState extends State<_N42ChatBootstrapWidget> {
  @override
  void initState() {
    super.initState();
    _waitForInitialization();
  }

  Future<void> _waitForInitialization() async {
    final pendingInitialization = N42Chat._initCompleter;
    if (pendingInitialization == null) return;
    try {
      await pendingInitialization.future;
    } catch (_) {}
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (N42Chat.isInitialized) {
      return const _N42ChatEntryWidget();
    }
    if (N42Chat._initCompleter != null) {
      return const _LoadingPage();
    }
    return const _NotInitializedPage();
  }
}

class _N42ProfileBootstrapWidget extends StatefulWidget {
  final bool showAppBar;

  const _N42ProfileBootstrapWidget({required this.showAppBar});

  @override
  State<_N42ProfileBootstrapWidget> createState() =>
      _N42ProfileBootstrapWidgetState();
}

class _N42ProfileBootstrapWidgetState
    extends State<_N42ProfileBootstrapWidget> {
  @override
  void initState() {
    super.initState();
    _waitForInitialization();
  }

  Future<void> _waitForInitialization() async {
    final pendingInitialization = N42Chat._initCompleter;
    if (pendingInitialization == null) return;
    try {
      await pendingInitialization.future;
    } catch (_) {}
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (N42Chat.isInitialized) {
      return _N42ProfileEntryWidget(showAppBar: widget.showAppBar);
    }
    if (N42Chat._initCompleter != null) {
      return const _LoadingPage();
    }
    return const _NotInitializedPage();
  }
}

/// 未初始化错误页面
class _NotInitializedPage extends StatefulWidget {
  const _NotInitializedPage();

  @override
  State<_NotInitializedPage> createState() => _NotInitializedPageState();
}

class _NotInitializedPageState extends State<_NotInitializedPage> {
  bool _isRetrying = false;

  Future<void> _retry() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      // 尝试重新初始化
      await N42Chat.initialize(N42Chat.config ?? const N42ChatConfig());
      // 如果成功，触发重建
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugLog('N42Chat retry initialization failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果已初始化，返回正常的入口Widget
    if (N42Chat.isInitialized) {
      return const _N42ChatEntryWidget();
    }

    final isDark = context.isDarkMode;
    final bgColor = AppColors.bgOf(isDark);
    final textColor = AppColors.textPrimaryOf(isDark);
    final subtitleColor = AppColors.textSecondaryOf(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.orange,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'N42 Chat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Chat initialization failed',
                style: TextStyle(fontSize: 16, color: subtitleColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your network and try again',
                style: TextStyle(fontSize: 14, color: subtitleColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 160,
                height: 44,
                child: ElevatedButton(
                  onPressed: _isRetrying ? null : _retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B6CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isRetrying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// N42 个人资料入口 Widget
///
/// 根据登录状态自动切换页面：
/// - 已登录：显示个人资料页
/// - 未登录：显示欢迎页面（引导登录）
class _N42ProfileEntryWidget extends StatefulWidget {
  final bool showAppBar;

  const _N42ProfileEntryWidget({this.showAppBar = true});

  @override
  State<_N42ProfileEntryWidget> createState() => _N42ProfileEntryWidgetState();
}

class _N42ProfileEntryWidgetState extends State<_N42ProfileEntryWidget> {
  Locale _currentLocale = _N42ThemeManager._locale;
  FontSize _fontSize = N42Chat.fontSize;

  @override
  void initState() {
    super.initState();
    N42Chat.addLocaleListener(_onLocaleChanged);
    N42Chat.addThemeListener(_onThemeChanged);
    N42Chat.addFontSizeListener(_onFontSizeChanged);
    unawaited(_loadAppearanceSettings());
    // 检查当前登录状态
    N42Chat.authBloc.add(const AuthCheckRequested());
  }

  void _onLocaleChanged(Locale locale) {
    if (mounted) setState(() => _currentLocale = locale);
  }

  void _onThemeChanged(ThemeMode _) {
    if (mounted) setState(() {});
  }

  void _onFontSizeChanged(FontSize fontSize) {
    if (mounted) setState(() => _fontSize = fontSize);
  }

  Future<void> _loadAppearanceSettings() async {
    try {
      final appearanceSettings = await N42Chat.getSavedAppearanceSettings();
      if (!mounted) return;
      // 宿主接管明暗模式时不要用自存值覆盖宿主下发的 themeMode，
      // 否则每次打开 chat 都会把宿主设置还原。字体大小仍由 chat 自身管理。
      if (!N42Chat.hostControlsAppearance) {
        N42Chat.setThemeMode(appearanceSettings.themeMode);
      }
      N42Chat.setFontSize(appearanceSettings.fontSize);
    } catch (e) {
      debugLog('N42Chat: Failed to load appearance settings: $e');
    }
  }

  @override
  void dispose() {
    N42Chat.removeLocaleListener(_onLocaleChanged);
    N42Chat.removeThemeListener(_onThemeChanged);
    N42Chat.removeFontSizeListener(_onFontSizeChanged);
    super.dispose();
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: N42Chat.authBloc,
          child: const LoginPage(),
        ),
      ),
    );
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: N42Chat.authBloc,
          child: const RegisterPage(),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _wrapChatPresentation(
      context,
      locale: _currentLocale,
      fontSize: _fontSize,
      child: BlocProvider.value(
        value: N42Chat.authBloc,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // 检查中或初始状态 - 显示加载
            if (state.status == AuthStatus.initial ||
                state.status == AuthStatus.checking) {
              return const _LoadingPage();
            }

            // 已登录 - 显示个人资料页
            if (state.isAuthenticated) {
              return ProfilePage(showAppBar: widget.showAppBar);
            }

            // 未登录 - 显示欢迎页面
            return WelcomePage(
              onLogin: () => _navigateToLogin(context),
              onRegister: () => _navigateToRegister(context),
              onBack: () => N42Chat.requestBackToHost(context),
              onTermsOfService: () => _launchUrl(
                N42Chat._config?.termsOfServiceUrl ??
                    'https://www.n42.ai/static/terms_of_use.html',
              ),
              onPrivacyPolicy: () => _launchUrl(
                N42Chat._config?.privacyPolicyUrl ??
                    'https://www.n42.ai/static/terms_of_use.html',
              ),
            );
          },
        ),
      ),
    );
  }
}

double _fontPreferenceScale(FontSize fontSize) {
  switch (fontSize) {
    case FontSize.small:
      return 0.94;
    case FontSize.medium:
      return 1.0;
    case FontSize.large:
      return 1.06;
    case FontSize.extraLarge:
      return 1.12;
  }
}

double _chatBaseTextScale(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return screenWidth >= 600 ? 0.97 : 0.94;
}

double _chatTextScale(BuildContext context, FontSize fontSize) {
  final mediaQuery = MediaQuery.of(context);
  final inheritedScale = mediaQuery.textScaler.scale(16) / 16;
  final adjustedScale =
      inheritedScale *
      _chatBaseTextScale(context) *
      _fontPreferenceScale(fontSize);
  return adjustedScale.clamp(0.88, 1.18);
}

ThemeData _buildChatScopedTheme(ThemeData baseTheme) {
  final isDark = baseTheme.brightness == Brightness.dark;
  final textTheme = baseTheme.textTheme;
  final chromeColor = isDark
      ? const Color(0xFF161A22)
      : const Color(0xFFF6F8FB);
  final cardColor = isDark ? const Color(0xFF1C212B) : Colors.white;
  final dividerColor = isDark
      ? const Color(0xFF2B3140)
      : const Color(0xFFE6EBF2);
  final appBarTitleStyle =
      (baseTheme.appBarTheme.titleTextStyle ?? textTheme.titleLarge)?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.2,
      );

  return baseTheme.copyWith(
    scaffoldBackgroundColor: chromeColor,
    cardColor: cardColor,
    appBarTheme: baseTheme.appBarTheme.copyWith(
      centerTitle: true,
      backgroundColor: chromeColor,
      foregroundColor: isDark ? Colors.white : const Color(0xFF141B24),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: appBarTitleStyle,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: cardColor,
      surfaceTintColor: Colors.transparent,
      elevation: isDark ? 6 : 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: textTheme.bodyMedium?.copyWith(height: 1.25),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cardColor,
      modalBackgroundColor: cardColor,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: isDark ? const Color(0xFF232938) : const Color(0xFFF3F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: baseTheme.colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
    ),
    listTileTheme: baseTheme.listTileTheme.copyWith(
      tileColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      minVerticalPadding: 8,
    ),
    dividerTheme: baseTheme.dividerTheme.copyWith(
      color: dividerColor,
      thickness: 0.6,
      space: 0,
    ),
    textTheme: textTheme.copyWith(
      titleLarge: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.2,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.24,
        letterSpacing: -0.15,
      ),
      titleSmall: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.24,
        letterSpacing: -0.1,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        height: 1.34,
        letterSpacing: -0.05,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        height: 1.34,
        letterSpacing: -0.05,
      ),
      bodySmall: textTheme.bodySmall?.copyWith(
        height: 1.3,
        letterSpacing: -0.02,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.05,
      ),
    ),
  );
}

Widget _wrapChatPresentation(
  BuildContext context, {
  required Widget child,
  required FontSize fontSize,
  Locale? locale,
}) {
  final mediaQuery = MediaQuery.of(context);
  final parentTheme = Theme.of(context);
  final useDark = N42Chat.isDarkMode(context);
  final fallbackTheme = useDark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);
  final baseTheme =
      parentTheme.brightness == (useDark ? Brightness.dark : Brightness.light)
      ? parentTheme
      : fallbackTheme.copyWith(
          textTheme: parentTheme.textTheme,
          primaryTextTheme: parentTheme.primaryTextTheme,
          iconTheme: parentTheme.iconTheme,
          platform: parentTheme.platform,
          visualDensity: parentTheme.visualDensity,
          materialTapTargetSize: parentTheme.materialTapTargetSize,
          pageTransitionsTheme: parentTheme.pageTransitionsTheme,
        );
  final scopedTheme = _buildChatScopedTheme(baseTheme);
  Widget wrappedChild = Theme(
    data: scopedTheme,
    child: MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: TextScaler.linear(_chatTextScale(context, fontSize)),
      ),
      child: child,
    ),
  );

  if (locale != null) {
    wrappedChild = Localizations.override(
      context: context,
      locale: locale,
      delegates: S.localizationsDelegates,
      child: wrappedChild,
    );
  }

  return wrappedChild;
}
