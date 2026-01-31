// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

// Example main.dart with Riverpod integration
//
// This demonstrates the migration path from Provider to Riverpod.
// During migration, both systems can coexist.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;

// Core
import 'package:n42appv2/core/di/injection.dart';
import 'package:n42appv2/core/providers/core_providers.dart';

// Legacy Providers (to be removed after migration)
import 'package:n42appv2/src/state/public_provider.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/browser/provider/browser_provider.dart';
import 'package:n42appv2/src/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42appv2/src/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42appv2/src/miningV2/provider/mining_v2_provider.dart';

// Themes
import 'package:n42appv2/presentation/themes/theme_adapter.dart';

// Generated
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Global ProviderContainer for Riverpod
late ProviderContainer globalProviderContainer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Create Riverpod ProviderContainer
  globalProviderContainer = ProviderContainer();

  // Initialize Dependency Injection
  await configureDependencies(
    Env.prod,
    container: globalProviderContainer,
  );

  // Setup error handling
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    // Wrap with UncontrolledProviderScope for Riverpod
    UncontrolledProviderScope(
      container: globalProviderContainer,
      child: legacy_provider.MultiProvider(
        // Keep legacy providers during migration
        providers: [
          legacy_provider.ChangeNotifierProvider<PublicProvider>(
            create: (_) => PublicProvider(),
          ),
          legacy_provider.ChangeNotifierProvider<BrowserProvider>(
            create: (_) => BrowserProvider(),
          ),
          legacy_provider.ChangeNotifierProvider<WalletConnectProvider>(
            create: (_) => WalletConnectProvider(),
          ),
          legacy_provider.ChangeNotifierProvider<WalletActionProvider>(
            create: (_) => WalletActionProvider(),
          ),
          legacy_provider.ChangeNotifierProvider<TransactionRecordItemProvider>(
            create: (_) => TransactionRecordItemProvider(),
          ),
          legacy_provider.ChangeNotifierProvider<MiningV2Provider>(
            create: (_) => MiningV2Provider(),
          ),
        ],
        child: const N42App(),
      ),
    ),
  );
}

/// Main App Widget using ConsumerStatefulWidget
class N42App extends ConsumerStatefulWidget {
  const N42App({super.key});

  @override
  ConsumerState<N42App> createState() => _N42AppState();
}

class _N42AppState extends ConsumerState<N42App> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Mark app as initialized
    ref.read(appInitializedProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    // Watch Riverpod providers for theme and locale
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'N42 Wallet',
      debugShowCheckedModeBanner: false,

      // Theme from Riverpod
      theme: ThemeAdapter.themeDataLight,
      darkTheme: ThemeAdapter.themeDataDark,
      themeMode: themeMode,

      // Locale from Riverpod
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      // Home page
      home: const AppInitializer(),
    );
  }
}

/// App Initializer - handles initial loading state
class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInitialized = ref.watch(appInitializedProvider);

    if (!isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Return your home page
    // For now, return a placeholder
    return const Scaffold(
      body: Center(
        child: Text('N42 Wallet'),
      ),
    );
  }
}

