// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// Auth Feature Module
///
/// This module handles all authentication-related functionality:
/// - User login and registration
/// - Password management
/// - Security settings
/// - Google authenticator
library auth;

// Domain Layer
export 'domain/entities/auth_entity.dart';
export 'domain/repositories/auth_repository.dart';

// Presentation Layer - To be migrated from lib/src/login/
// export 'presentation/providers/auth_provider.dart';
// export 'presentation/pages/login_page.dart';
