# Production Readiness Audit: n42-mobile-ffi
Generated: 2026-02-21

| Area | Issue | Severity | File:Line |
|------|-------|----------|-----------|
| Error Handling | `unwrap()` in tracing init — panics if env filter parsing fails | **Critical** | lib.rs:166 |
| Error Handling | `unwrap()` on IdleTimeout conversion | **High** | lib.rs:728 |
| Error Handling | `packet.header_info().unwrap_or((0, B256::ZERO))` silently defaults on parse failure | **High** | lib.rs:379 |
| Error Handling | Stream finish error silently ignored via `let _ = stream.finish()` | **Medium** | lib.rs:519 |
| Error Propagation | Receipt sending in `n42_verify_and_send` silently logs failures instead of propagating | **High** | lib.rs:513-525 |
| Error Propagation | `recv_loop` silently continues on decompression failures | **Medium** | lib.rs:844-846, 910-912 |
| Error Propagation | `recv_loop` silently continues on cache sync decode failures | **Medium** | lib.rs:876-878, 905-907 |
| Design | Receipt transmission is fire-and-forget — no confirmation or retry | **High** | lib.rs:513-526 |
| Unsafe Blocks | 114 `unsafe` instances — large attack surface for FFI | **High** | Multiple |
| Unsafe Blocks | Pointer arithmetic `out_buf.add(json.len())` — relies on correct buffer sizing | **Medium** | lib.rs:569, 656 |
| Hardcoded Values | QUIC idle timeout: 300 s (not configurable) | **Medium** | lib.rs:728 |
| Hardcoded Values | QUIC keep-alive: 15 s (not configurable) | **Medium** | lib.rs:730 |
| Hardcoded Values | Connection establishment timeout: 10 s (not configurable) | **Medium** | lib.rs:742 |
| Hardcoded Values | Stream read / decompress / cache-sync limit: 16 MB (duplicated) | **Medium** | lib.rs:798, 825, 851, 883 |
| Hardcoded Values | MAX_PENDING_PACKETS: 64 (not configurable) | **Low** | lib.rs:95 |
| Hardcoded Values | DEFAULT_CODE_CACHE_CAPACITY: 1000 (not configurable) | **Low** | lib.rs:98 |
| Test Coverage | No integration tests for `connect_quic` async path | **High** | lib.rs:711 |
| Test Coverage | No integration tests for `recv_loop` background task | **High** | lib.rs:788 |
| Test Coverage | No tests for concurrent access / mutex poison recovery | **Medium** | lib.rs:25-29 |
| Resource Management | Dropped packets counter never reset — potential overflow on long-running nodes | **Medium** | lib.rs:813, 834 |
| Initialization | Tracing init swallows all errors silently | **Medium** | lib.rs:160-169 |
| Timestamp | `unwrap_or_default()` silently falls back to epoch if system clock fails | **Medium** | lib.rs:447-450 |

## Totals: Critical 1 · High 6 · Medium 13 · Low 4
