// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// Public crypto/news RSS feeds used by the app's news surfaces.
///
/// Keep this list broad: individual publishers occasionally change feed
/// behaviour or block specific clients, so the fetchers merge whichever feeds
/// are reachable instead of depending on a single endpoint.
class CryptoNewsFeeds {
  const CryptoNewsFeeds._();

  static const urls = <String>[
    'https://cointelegraph.com/rss',
    'https://decrypt.co/feed',
    'https://www.coindesk.com/arc/outboundfeeds/rss?outputType=xml',
    'https://cryptoslate.com/feed/',
    'https://cryptonews.com/news/feed/',
    'https://beincrypto.com/feed/',
    'https://cryptopotato.com/feed/',
    'https://thedefiant.io/api/feed',
  ];
}
