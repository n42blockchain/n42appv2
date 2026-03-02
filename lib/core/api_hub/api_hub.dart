// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// API Hub — multi-source data aggregation layer.
///
/// Provides fallback chains for market data, news, DeFi metrics,
/// and URL security checks using free, no-key-required APIs.
library;

// Models
export 'models/coin_price.dart';
export 'models/defi_protocol.dart';
export 'models/url_threat.dart';

// Datasources
export 'datasources/coincap_datasource.dart';
export 'datasources/coinpaprika_datasource.dart';
export 'datasources/cryptocompare_price_datasource.dart';
export 'datasources/coinlore_datasource.dart';
export 'datasources/messari_datasource.dart';
export 'datasources/defillama_datasource.dart';
export 'datasources/urlhaus_datasource.dart';

// Aggregators
export 'aggregators/market_data_aggregator.dart';
export 'aggregators/news_aggregator.dart';
export 'aggregators/url_security_aggregator.dart';
