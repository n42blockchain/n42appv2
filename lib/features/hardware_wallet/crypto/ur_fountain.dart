// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';
import 'dart:typed_data';

import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'ur_codec.dart';

/// BC-UR fountain 多帧编解码（BCR-2020-005 §Multi-part）。
///
/// 逐比特移植自 Blockchain Commons 参考实现 bc-ur（BSD-2-Clause Plus
/// Patent License），全部算法常量与随机数语义以参考实现为准，并由
/// `test/features/hardware_wallet/ur_fountain_test.dart` 中的官方测试
/// 向量守护——**任何"看起来等价"的改写都可能破坏与真机硬件钱包的互操作**。
///
/// 管线：
///   encode: message → 分片(等长补零) → fountain 混合(XOR) →
///           Part CBOR [seqNum,seqLen,messageLen,checksum,data] →
///           `ur:type/seqNum-seqLen/minimal-bytewords`
///   decode: 逐帧收取 → 同参数重算混合集 → 置信传播消元 → 拼回 message

final BigInt _mask64 = (BigInt.one << 64) - BigInt.one;

/// Xoshiro256**（Blackman & Vigna 2018），种子 = SHA-256(input)，
/// 摘要按 8 字节大端一组填入 4 个 64 位状态字。
///
/// 用 BigInt 实现以获得精确的 64 位无符号语义（next()/2^64 的
/// double 转换必须与参考实现单次舍入一致）。
class Xoshiro256 {
  final List<BigInt> _s;

  Xoshiro256._(this._s);

  /// 以任意字节串做种（内部先 SHA-256）
  factory Xoshiro256.fromBytes(List<int> seed) {
    final digest = sha256.convert(seed).bytes;
    final s = List<BigInt>.filled(4, BigInt.zero);
    for (var i = 0; i < 4; i++) {
      var v = BigInt.zero;
      for (var n = 0; n < 8; n++) {
        v = (v << 8) | BigInt.from(digest[i * 8 + n]);
      }
      s[i] = v;
    }
    return Xoshiro256._(s);
  }

  factory Xoshiro256.fromString(String seed) =>
      Xoshiro256.fromBytes(utf8.encode(seed));

  factory Xoshiro256.fromCrc32(int checksum) =>
      Xoshiro256.fromBytes(_intToBytesBE(checksum));

  static BigInt _rotl(BigInt x, int k) =>
      ((x << k) | (x >> (64 - k))) & _mask64;

  BigInt next() {
    final result =
        (_rotl((_s[1] * BigInt.from(5)) & _mask64, 7) * BigInt.from(9)) &
            _mask64;
    final t = (_s[1] << 17) & _mask64;
    _s[2] ^= _s[0];
    _s[3] ^= _s[1];
    _s[1] ^= _s[2];
    _s[0] ^= _s[3];
    _s[2] ^= t;
    _s[3] = _rotl(_s[3], 45);
    return result;
  }

  /// [0, 1) 双精度：无符号 64 位值单次舍入后除以 2^64（与参考一致）
  double nextDouble() => next().toDouble() / 18446744073709551616.0;

  /// [low, high] 均匀整数（参考实现的 double 截断语义）
  int nextInt(int low, int high) =>
      (nextDouble() * (high - low + 1)).toInt() + low;

  int nextByte() => nextInt(0, 255);

  Uint8List nextData(int count) =>
      Uint8List.fromList([for (var i = 0; i < count; i++) nextByte()]);
}

Uint8List _intToBytesBE(int v) => Uint8List(4)
  ..[0] = (v >> 24) & 0xFF
  ..[1] = (v >> 16) & 0xFF
  ..[2] = (v >> 8) & 0xFF
  ..[3] = v & 0xFF;

/// Walker/Vose alias-method 加权采样。
///
/// 表构造顺序（含"倒序入栈"这一与 Schwarz 原文的刻意差异）必须与
/// 参考实现一致，否则采样序列不同 → 混合帧片段集不同 → 无法互通。
class RandomSampler {
  late final List<double> _probs;
  late final List<int> _aliases;

  RandomSampler(List<double> probs) {
    assert(probs.every((p) => p >= 0));
    final sum = probs.fold(0.0, (a, b) => a + b);
    assert(sum > 0);
    final n = probs.length;

    final p = [for (final d in probs) d * n / sum];

    final small = <int>[];
    final large = <int>[];
    // at variance from Schwarz, we reverse the index order
    for (var i = n - 1; i >= 0; i--) {
      (p[i] < 1 ? small : large).add(i);
    }

    final outProbs = List<double>.filled(n, 0);
    final outAliases = List<int>.filled(n, 0);
    while (small.isNotEmpty && large.isNotEmpty) {
      final a = small.removeLast();
      final g = large.removeLast();
      outProbs[a] = p[a];
      outAliases[a] = g;
      p[g] += p[a] - 1;
      (p[g] < 1 ? small : large).add(g);
    }
    while (large.isNotEmpty) {
      outProbs[large.removeLast()] = 1;
    }
    while (small.isNotEmpty) {
      // 只会因数值不稳定出现
      outProbs[small.removeLast()] = 1;
    }
    _probs = outProbs;
    _aliases = outAliases;
  }

  int next(double Function() rng) {
    final r1 = rng();
    final r2 = rng();
    final i = (_probs.length * r1).toInt();
    return r2 < _probs[i] ? i : _aliases[i];
  }
}

/// 度数分布：P(d) ∝ 1/d，d ∈ [1, seqLen]
@visibleForTesting
int chooseDegree(int seqLen, Xoshiro256 rng) {
  final probs = [for (var i = 1; i <= seqLen; i++) 1.0 / i];
  return RandomSampler(probs).next(rng.nextDouble) + 1;
}

/// 参考实现的抽取式洗牌（非 Fisher-Yates 原地交换——顺序语义不同）
@visibleForTesting
List<int> shuffled(List<int> items, Xoshiro256 rng) {
  final remaining = List<int>.of(items);
  final result = <int>[];
  while (remaining.isNotEmpty) {
    final index = rng.nextInt(0, remaining.length - 1);
    result.add(remaining.removeAt(index));
  }
  return result;
}

/// 给定帧序号计算它混合了哪些片段。
///
/// 前 seqLen 帧是纯片段（只要连续收满前 seqLen 帧即可还原全文）；
/// 之后的帧由 (seqNum, checksum) 播种的 PRNG 决定混合集。
Set<int> chooseFragments(int seqNum, int seqLen, int checksum) {
  if (seqNum <= seqLen) {
    return {seqNum - 1};
  }
  final seed = Uint8List.fromList([
    ..._intToBytesBE(seqNum),
    ..._intToBytesBE(checksum),
  ]);
  final rng = Xoshiro256.fromBytes(seed);
  final degree = chooseDegree(seqLen, rng);
  final indexes = [for (var i = 0; i < seqLen; i++) i];
  final shuffledIndexes = shuffled(indexes, rng);
  return shuffledIndexes.take(degree).toSet();
}

/// 一个 fountain 帧：`[seqNum, seqLen, messageLen, checksum, data]`
class FountainPart {
  final int seqNum;
  final int seqLen;
  final int messageLen;
  final int checksum;
  final Uint8List data;

  const FountainPart({
    required this.seqNum,
    required this.seqLen,
    required this.messageLen,
    required this.checksum,
    required this.data,
  });

  Uint8List toCbor() {
    return Uint8List.fromList(
      CborListValue.definite(<CborObject>[
        CborIntValue(seqNum),
        CborIntValue(seqLen),
        CborIntValue(messageLen),
        CborIntValue(checksum),
        CborBytesValue(data),
      ]).encode(),
    );
  }

  factory FountainPart.fromCbor(Uint8List cbor) {
    final obj = CborObject.fromCbor(cbor);
    if (obj is! CborListValue || obj.value.length != 5) {
      throw UrCodecException('Invalid fountain part: expected 5-element array');
    }
    final items = obj.value;
    int asInt(Object? v) {
      if (v is CborNumeric) return v.toInt();
      throw UrCodecException('Invalid fountain part: expected integer field');
    }

    final dataField = items[4];
    if (dataField is! CborBytesValue) {
      throw UrCodecException('Invalid fountain part: expected bytes field');
    }
    return FountainPart(
      seqNum: asInt(items[0]),
      seqLen: asInt(items[1]),
      messageLen: asInt(items[2]),
      checksum: asInt(items[3]),
      data: Uint8List.fromList(dataField.value),
    );
  }

  String get description =>
      'seqNum:$seqNum, seqLen:$seqLen, messageLen:$messageLen, '
      'checksum:$checksum, data:${_hex(data)}';
}

String _hex(Uint8List data) =>
    data.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void _xorInto(Uint8List target, Uint8List source) {
  assert(target.length == source.length);
  for (var i = 0; i < target.length; i++) {
    target[i] ^= source[i];
  }
}

/// Fountain 编码器：无限生成帧序列，接收端集齐任意"可解组合"即可还原。
class FountainEncoder {
  final int messageLen;
  final int checksum;
  final int fragmentLen;
  final List<Uint8List> _fragments;
  int _seqNum;

  int get seqLen => _fragments.length;
  int get seqNum => _seqNum;

  /// 生成的帧数已覆盖全部纯片段（对固定展示列表而言"够了"；
  /// 动画 QR 应继续调用 [nextPart] 无限轮播以提高扫码成功率）
  bool get isComplete => _seqNum >= seqLen;

  bool get isSinglePart => seqLen == 1;

  FountainEncoder._({
    required this.messageLen,
    required this.checksum,
    required this.fragmentLen,
    required List<Uint8List> fragments,
    required int firstSeqNum,
  })  : _fragments = fragments,
        _seqNum = firstSeqNum;

  factory FountainEncoder(
    Uint8List message, {
    required int maxFragmentLen,
    int firstSeqNum = 0,
    int minFragmentLen = 10,
  }) {
    final fragmentLen = findNominalFragmentLength(
      message.length,
      minFragmentLen,
      maxFragmentLen,
    );
    return FountainEncoder._(
      messageLen: message.length,
      checksum: UrCodec.crc32Int(message),
      fragmentLen: fragmentLen,
      fragments: partitionMessage(message, fragmentLen),
      firstSeqNum: firstSeqNum,
    );
  }

  /// 选最小的分片数使每片长度 ≤ maxFragmentLen，全部等长
  static int findNominalFragmentLength(
    int messageLen,
    int minFragmentLen,
    int maxFragmentLen,
  ) {
    assert(messageLen > 0 && minFragmentLen > 0);
    assert(maxFragmentLen >= minFragmentLen);
    final maxFragmentCount =
        (messageLen ~/ minFragmentLen).clamp(1, messageLen);
    var fragmentLen = messageLen;
    for (var fragmentCount = 1;
        fragmentCount <= maxFragmentCount;
        fragmentCount++) {
      fragmentLen = (messageLen / fragmentCount).ceil();
      if (fragmentLen <= maxFragmentLen) break;
    }
    return fragmentLen;
  }

  /// 等长切片，末片补零
  static List<Uint8List> partitionMessage(Uint8List message, int fragmentLen) {
    final fragments = <Uint8List>[];
    var offset = 0;
    while (offset < message.length) {
      final fragment = Uint8List(fragmentLen);
      final end = (offset + fragmentLen).clamp(0, message.length);
      fragment.setRange(0, end - offset, message, offset);
      fragments.add(fragment);
      offset = end;
    }
    return fragments;
  }

  Uint8List _mix(Set<int> indexes) {
    final result = Uint8List(fragmentLen);
    for (final index in indexes) {
      _xorInto(result, _fragments[index]);
    }
    return result;
  }

  FountainPart nextPart() {
    _seqNum = (_seqNum + 1) & 0xFFFFFFFF; // wrap at 2^32
    final indexes = chooseFragments(_seqNum, seqLen, checksum);
    return FountainPart(
      seqNum: _seqNum,
      seqLen: seqLen,
      messageLen: messageLen,
      checksum: checksum,
      data: _mix(indexes),
    );
  }
}

/// Fountain 解码器：收帧 → 置信传播消元 → 集齐纯片段后拼回并校验 CRC。
class FountainDecoder {
  Set<int>? _expectedPartIndexes;
  int? _expectedMessageLen;
  int? _expectedChecksum;
  int? _expectedFragmentLen;

  final Set<int> _receivedPartIndexes = {};
  final Map<String, _DecoderPart> _simpleParts = {};
  final Map<String, _DecoderPart> _mixedParts = {};
  final List<_DecoderPart> _queuedParts = [];
  int _processedPartsCount = 0;

  Uint8List? _resultMessage;
  String? _resultError;

  bool get isComplete => _resultMessage != null || _resultError != null;
  bool get isSuccess => _resultMessage != null;
  bool get isFailure => _resultError != null;
  Uint8List? get resultMessage => _resultMessage;
  String? get resultError => _resultError;

  int? get expectedPartCount => _expectedPartIndexes?.length;
  int get processedPartsCount => _processedPartsCount;
  Set<int> get receivedPartIndexes => Set.unmodifiable(_receivedPartIndexes);

  double get estimatedPercentComplete {
    if (isComplete) return 1;
    final expected = expectedPartCount;
    if (expected == null) return 0;
    final estimatedInputParts = expected * 1.75;
    final p = _processedPartsCount / estimatedInputParts;
    return p < 0.99 ? p : 0.99;
  }

  static Uint8List joinFragments(List<Uint8List> fragments, int messageLen) {
    final joined = Uint8List.fromList(
      [for (final f in fragments) ...f],
    );
    return Uint8List.sublistView(joined, 0, messageLen);
  }

  bool receivePart(FountainPart encoderPart) {
    if (isComplete) return false;
    if (!_validatePart(encoderPart)) return false;

    final part = _DecoderPart(
      chooseFragments(
        encoderPart.seqNum,
        encoderPart.seqLen,
        encoderPart.checksum,
      ),
      encoderPart.data,
    );
    _queuedParts.add(part);

    while (!isComplete && _queuedParts.isNotEmpty) {
      final item = _queuedParts.removeAt(0);
      if (item.isSimple) {
        _processSimplePart(item);
      } else {
        _processMixedPart(item);
      }
    }

    _processedPartsCount += 1;
    return true;
  }

  bool _validatePart(FountainPart p) {
    final expected = _expectedPartIndexes;
    if (expected == null) {
      _expectedPartIndexes = {for (var i = 0; i < p.seqLen; i++) i};
      _expectedMessageLen = p.messageLen;
      _expectedChecksum = p.checksum;
      _expectedFragmentLen = p.data.length;
      return true;
    }
    return expected.length == p.seqLen &&
        _expectedMessageLen == p.messageLen &&
        _expectedChecksum == p.checksum &&
        _expectedFragmentLen == p.data.length;
  }

  void _processSimplePart(_DecoderPart p) {
    final fragmentIndex = p.indexes.first;
    if (_receivedPartIndexes.contains(fragmentIndex)) return;

    _simpleParts[p.key] = p;
    _receivedPartIndexes.add(fragmentIndex);

    if (_receivedPartIndexes.length == _expectedPartIndexes!.length) {
      final sorted = _simpleParts.values.toList()
        ..sort((a, b) => a.indexes.first.compareTo(b.indexes.first));
      final message = joinFragments(
        [for (final part in sorted) part.data],
        _expectedMessageLen!,
      );
      if (UrCodec.crc32Int(message) == _expectedChecksum) {
        _resultMessage = message;
      } else {
        _resultError = 'Invalid checksum';
      }
    } else {
      _reduceMixedBy(p);
    }
  }

  void _processMixedPart(_DecoderPart p) {
    if (_mixedParts.containsKey(p.key)) return;

    var reduced = p;
    for (final simple in _simpleParts.values) {
      reduced = _reducePartByPart(reduced, simple);
    }
    for (final mixed in _mixedParts.values) {
      reduced = _reducePartByPart(reduced, mixed);
    }

    if (reduced.isSimple) {
      _queuedParts.add(reduced);
    } else {
      _reduceMixedBy(reduced);
      _mixedParts[reduced.key] = reduced;
    }
  }

  void _reduceMixedBy(_DecoderPart p) {
    final reducedParts = [
      for (final mixed in _mixedParts.values) _reducePartByPart(mixed, p),
    ];
    _mixedParts.clear();
    for (final reduced in reducedParts) {
      if (reduced.isSimple) {
        _queuedParts.add(reduced);
      } else {
        _mixedParts[reduced.key] = reduced;
      }
    }
  }

  /// 若 b 的片段集是 a 的真子集：a 消去 b（索引差集，数据 XOR）
  _DecoderPart _reducePartByPart(_DecoderPart a, _DecoderPart b) {
    final isStrictSubset = b.indexes.length < a.indexes.length &&
        a.indexes.containsAll(b.indexes);
    if (!isStrictSubset) return a;
    final newIndexes = a.indexes.difference(b.indexes);
    final newData = Uint8List.fromList(a.data);
    _xorInto(newData, b.data);
    return _DecoderPart(newIndexes, newData);
  }
}

class _DecoderPart {
  final Set<int> indexes;
  final Uint8List data;

  _DecoderPart(this.indexes, this.data);

  bool get isSimple => indexes.length == 1;

  /// 以排序索引串作为集合的规范键
  String get key => (indexes.toList()..sort()).join(',');
}

/// UR 层编码器：单帧输出 `ur:type/body`，多帧输出
/// `ur:type/seqNum-seqLen/body`（body 均为 minimal bytewords，CRC 内含）。
///
/// 输出为小写规范形式（与参考实现测试向量一致）；QR 展示时可
/// `.toUpperCase()` 换取更高密度的 alphanumeric 模式，语义不变。
class UrEncoder {
  final String type;
  final Uint8List _messageCbor;
  final FountainEncoder _fountain;

  UrEncoder(
    this.type,
    Uint8List cborPayload, {
    int maxFragmentLen = 120,
    int firstSeqNum = 0,
    int minFragmentLen = 10,
  })  : _messageCbor = cborPayload,
        _fountain = FountainEncoder(
          cborPayload,
          maxFragmentLen: maxFragmentLen,
          firstSeqNum: firstSeqNum,
          minFragmentLen: minFragmentLen,
        );

  bool get isSinglePart => _fountain.isSinglePart;
  int get seqLen => _fountain.seqLen;

  String nextPart() {
    final part = _fountain.nextPart();
    if (isSinglePart) {
      return 'ur:$type/${UrCodec.encodeBytewordsBody(_messageCbor)}';
    }
    final body = UrCodec.encodeBytewordsBody(part.toCbor());
    return 'ur:$type/${part.seqNum}-${part.seqLen}/$body';
  }
}

/// UR 层解码器：逐帧喂入扫码结果（单帧与多帧皆可），完成后给出
/// (type, cbor payload)。无效帧返回 false 但不打断会话。
class UrDecoder {
  String? _expectedType;
  final FountainDecoder _fountain = FountainDecoder();
  ({String type, Uint8List data})? _result;
  String? _error;

  bool get isComplete => _result != null || _error != null;
  bool get isSuccess => _result != null;
  ({String type, Uint8List data})? get result => _result;
  String? get error => _error;

  String? get expectedType => _expectedType;
  int? get expectedPartCount => _fountain.expectedPartCount;
  int get receivedPartCount => _fountain.receivedPartIndexes.length;
  double get estimatedPercentComplete =>
      isComplete ? 1 : _fountain.estimatedPercentComplete;

  static final RegExp _urTypePattern = RegExp(r'^[a-z0-9-]+$');

  /// 喂入一帧扫码结果；返回该帧是否被采纳。
  bool receivePart(String s) {
    try {
      if (isComplete) return false;

      final lowered = s.toLowerCase().trim();
      if (!lowered.startsWith('ur:')) return false;
      final components = lowered.substring(3).split('/');
      if (components.length < 2) return false;

      final type = components.first;
      if (!_urTypePattern.hasMatch(type)) return false;
      if (_expectedType == null) {
        _expectedType = type;
      } else if (type != _expectedType) {
        return false;
      }

      // 单帧 UR：直接完成
      if (components.length == 2) {
        _result = (type: type, data: UrCodec.decodeBytewordsBody(components[1]));
        return true;
      }

      // 多帧必须恰为 type/seq/fragment 三段
      if (components.length != 3) return false;
      final seqMatch = RegExp(r'^(\d+)-(\d+)$').firstMatch(components[1]);
      if (seqMatch == null) return false;
      final seqNum = int.parse(seqMatch.group(1)!);
      final seqLen = int.parse(seqMatch.group(2)!);
      if (seqNum < 1 || seqLen < 1) return false;

      final cbor = UrCodec.decodeBytewordsBody(components[2]);
      final part = FountainPart.fromCbor(cbor);
      // 序号段与 CBOR 内的字段必须一致（防拼接篡改）
      if (seqNum != part.seqNum || seqLen != part.seqLen) return false;

      if (!_fountain.receivePart(part)) return false;

      if (_fountain.isSuccess) {
        _result = (type: type, data: _fountain.resultMessage!);
      } else if (_fountain.isFailure) {
        _error = _fountain.resultError;
      }
      return true;
    } on UrCodecException {
      return false;
    } on FormatException {
      return false;
    }
  }
}
