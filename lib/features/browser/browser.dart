// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// Browser Feature Module
///
/// DApp browser functionality including:
/// - WebView management
/// - Bookmark/collection handling
/// - History tracking
/// - DApp interaction
library browser;

// Data Layer
export 'data/api/browser_api.dart';
export 'data/models/browser_collection_model.dart';
export 'data/models/browser_history_model.dart';

// Presentation Layer
export 'presentation/providers/browser_provider.dart';
export 'presentation/pages/browser_page.dart';

