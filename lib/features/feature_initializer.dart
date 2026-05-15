// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/shared/contracts/feature_contracts.dart';

/// Feature Initializer
///
/// Manages the initialization order and dependencies of all features
/// via topological sort over [IFeatureModule.dependencies].
///
/// **Status: designed but not wired.** [featureInitializer] (the global
/// instance below) has zero call sites, and no class in the codebase
/// implements [IFeatureModule]. The current bootstrap path runs
/// initialisation directly from `main()` / `configureDependencies()` /
/// per-feature Riverpod providers, which has so far been simpler than
/// declaring a module graph here.
///
/// Kept as the canonical reference for the planned module-aware
/// bootstrap; revive in tandem with [IFeatureModule] when there's a
/// concrete need for declarative dependency ordering across features.
class FeatureInitializer {
  static final FeatureInitializer _instance = FeatureInitializer._internal();
  factory FeatureInitializer() => _instance;
  FeatureInitializer._internal();

  final Map<String, IFeatureModule> _registeredFeatures = {};
  final Set<String> _initializedFeatures = {};
  bool _isInitialized = false;

  /// Register a feature module
  void registerFeature(IFeatureModule feature) {
    if (_registeredFeatures.containsKey(feature.featureId)) {
      AppLogger.w(
        'FeatureInitializer',
        'feature ${feature.featureId} already registered',
      );
      return;
    }
    _registeredFeatures[feature.featureId] = feature;
  }

  /// Initialize all registered features
  ///
  /// Respects dependency order - a feature will only be initialized
  /// after all its dependencies are initialized.
  Future<void> initializeAll() async {
    if (_isInitialized) {
      AppLogger.d('FeatureInitializer', 'already initialized');
      return;
    }

    final sortedFeatures = _topologicalSort();

    for (final featureId in sortedFeatures) {
      await _initializeFeature(featureId);
    }

    _isInitialized = true;
    AppLogger.i('FeatureInitializer', 'all features initialized');
  }

  /// Initialize a specific feature
  Future<void> _initializeFeature(String featureId) async {
    if (_initializedFeatures.contains(featureId)) {
      return;
    }

    final feature = _registeredFeatures[featureId];
    if (feature == null) {
      throw StateError('Feature $featureId not registered');
    }

    for (final depId in feature.dependencies) {
      if (!_initializedFeatures.contains(depId)) {
        await _initializeFeature(depId);
      }
    }

    try {
      await feature.initialize();
      _initializedFeatures.add(featureId);
      AppLogger.d('FeatureInitializer', 'initialized: ${feature.featureName}');
    } catch (e) {
      AppLogger.w('FeatureInitializer', 'failed to initialize $featureId: $e');
      rethrow;
    }
  }

  /// Topological sort of features based on dependencies
  List<String> _topologicalSort() {
    final sorted = <String>[];
    final visited = <String>{};
    final visiting = <String>{};

    void visit(String featureId) {
      if (visited.contains(featureId)) return;
      if (visiting.contains(featureId)) {
        throw StateError('Circular dependency detected involving $featureId');
      }

      visiting.add(featureId);

      final feature = _registeredFeatures[featureId];
      if (feature != null) {
        for (final depId in feature.dependencies) {
          if (_registeredFeatures.containsKey(depId)) {
            visit(depId);
          }
        }
      }

      visiting.remove(featureId);
      visited.add(featureId);
      sorted.add(featureId);
    }

    for (final featureId in _registeredFeatures.keys) {
      visit(featureId);
    }

    return sorted;
  }

  /// Dispose all features
  Future<void> disposeAll() async {
    final features = _initializedFeatures.toList().reversed;

    for (final featureId in features) {
      final feature = _registeredFeatures[featureId];
      if (feature != null) {
        try {
          feature.dispose();
          AppLogger.d('FeatureInitializer', 'disposed: ${feature.featureName}');
        } catch (e) {
          AppLogger.w('FeatureInitializer', 'failed to dispose $featureId: $e');
        }
      }
    }

    _initializedFeatures.clear();
    _registeredFeatures.clear();
    _isInitialized = false;
  }

  /// Check if a feature is initialized
  bool isFeatureInitialized(String featureId) {
    return _initializedFeatures.contains(featureId);
  }

  /// Get initialized features count
  int get initializedCount => _initializedFeatures.length;

  /// Get registered features count
  int get registeredCount => _registeredFeatures.length;
}

/// Global feature initializer instance
final featureInitializer = FeatureInitializer();

