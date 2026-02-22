// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

// Browser Feature Module
//
// This module handles all browser-related functionality:
// - Web browsing
// - History management
// - Bookmarks
// - DApp integration

// Domain Layer
export 'domain/entities/browser_entity.dart';
export 'domain/repositories/browser_repository.dart';

// Data Layer
export 'data/repositories/browser_repository_impl.dart';

// Presentation Layer - To be migrated from lib/src/browser/
// export 'presentation/providers/browser_provider.dart';
// export 'presentation/pages/browser_page.dart';
