// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Browser tab information
class BrowserTabInfo {
  final String url;
  final String title;
  final bool isLoading;
  final double progress;

  const BrowserTabInfo({
    required this.url,
    this.title = '',
    this.isLoading = false,
    this.progress = 0.0,
  });

  BrowserTabInfo copyWith({
    String? url,
    String? title,
    bool? isLoading,
    double? progress,
  }) {
    return BrowserTabInfo(
      url: url ?? this.url,
      title: title ?? this.title,
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
    );
  }
}

/// Browser state
class BrowserState {
  final List<BrowserTabInfo> tabs;
  final int currentIndex;
  final bool showTabList;
  final bool canGoBack;
  final bool canGoForward;
  final bool isCollected;
  final Map<String, dynamic> settings;

  const BrowserState({
    this.tabs = const [],
    this.currentIndex = -1,
    this.showTabList = false,
    this.canGoBack = false,
    this.canGoForward = false,
    this.isCollected = false,
    this.settings = const {},
  });

  BrowserState copyWith({
    List<BrowserTabInfo>? tabs,
    int? currentIndex,
    bool? showTabList,
    bool? canGoBack,
    bool? canGoForward,
    bool? isCollected,
    Map<String, dynamic>? settings,
  }) {
    return BrowserState(
      tabs: tabs ?? this.tabs,
      currentIndex: currentIndex ?? this.currentIndex,
      showTabList: showTabList ?? this.showTabList,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      isCollected: isCollected ?? this.isCollected,
      settings: settings ?? this.settings,
    );
  }

  /// Get current tab info
  BrowserTabInfo? get currentTab {
    if (currentIndex >= 0 && currentIndex < tabs.length) {
      return tabs[currentIndex];
    }
    return null;
  }

  /// Check if has tabs
  bool get hasTabs => tabs.isNotEmpty;
}

/// Browser state notifier
class BrowserStateNotifier extends StateNotifier<BrowserState> {
  BrowserStateNotifier() : super(const BrowserState());

  /// Add a new tab
  void addTab(String url) {
    final newTab = BrowserTabInfo(url: url);
    state = state.copyWith(
      tabs: [...state.tabs, newTab],
      currentIndex: state.tabs.length,
      showTabList: false,
    );
  }

  /// Switch to a tab
  void switchToTab(int index) {
    if (index >= 0 && index < state.tabs.length) {
      state = state.copyWith(
        currentIndex: index,
        showTabList: false,
      );
    }
  }

  /// Close a tab
  void closeTab(int index) {
    if (index < 0 || index >= state.tabs.length) return;

    final newTabs = List<BrowserTabInfo>.from(state.tabs)..removeAt(index);
    var newIndex = state.currentIndex;

    if (newTabs.isEmpty) {
      newIndex = -1;
    } else if (index <= state.currentIndex) {
      newIndex = (state.currentIndex - 1).clamp(0, newTabs.length - 1);
    }

    state = state.copyWith(
      tabs: newTabs,
      currentIndex: newIndex,
      showTabList: newTabs.isEmpty ? false : state.showTabList,
    );
  }

  /// Update current tab info
  void updateCurrentTab({
    String? url,
    String? title,
    bool? isLoading,
    double? progress,
  }) {
    if (state.currentIndex < 0 || state.currentIndex >= state.tabs.length) {
      return;
    }

    final currentTab = state.tabs[state.currentIndex];
    final updatedTab = currentTab.copyWith(
      url: url,
      title: title,
      isLoading: isLoading,
      progress: progress,
    );

    final newTabs = List<BrowserTabInfo>.from(state.tabs);
    newTabs[state.currentIndex] = updatedTab;

    state = state.copyWith(tabs: newTabs);
  }

  /// Toggle tab list visibility
  void toggleTabList() {
    state = state.copyWith(showTabList: !state.showTabList);
  }

  /// Update navigation state
  void updateNavigation({bool? canGoBack, bool? canGoForward}) {
    state = state.copyWith(
      canGoBack: canGoBack ?? state.canGoBack,
      canGoForward: canGoForward ?? state.canGoForward,
    );
  }

  /// Update collection state
  void setCollected(bool value) {
    state = state.copyWith(isCollected: value);
  }

  /// Update settings
  void updateSettings(Map<String, dynamic> settings) {
    state = state.copyWith(settings: {...state.settings, ...settings});
  }

  /// Clear all tabs
  void clearAllTabs() {
    state = const BrowserState();
  }
}

/// Browser state provider
///
/// This is the new Riverpod-based browser state management.
/// It coexists with the legacy BrowserProvider for gradual migration.
///
/// Usage:
/// ```dart
/// // Read state
/// final browserState = ref.watch(browserStateProvider);
/// final currentUrl = browserState.currentTab?.url;
///
/// // Modify state
/// ref.read(browserStateProvider.notifier).addTab('https://example.com');
/// ref.read(browserStateProvider.notifier).switchToTab(0);
/// ```
final browserStateProvider =
    StateNotifierProvider<BrowserStateNotifier, BrowserState>((ref) {
  return BrowserStateNotifier();
});

/// Current tab URL provider (derived)
final currentBrowserUrlProvider = Provider<String?>((ref) {
  final state = ref.watch(browserStateProvider);
  return state.currentTab?.url;
});

/// Tab count provider (derived)
final browserTabCountProvider = Provider<int>((ref) {
  return ref.watch(browserStateProvider).tabs.length;
});

/// Is browser loading provider (derived)
final isBrowserLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(browserStateProvider);
  return state.currentTab?.isLoading ?? false;
});
