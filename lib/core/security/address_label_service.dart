import 'dart:convert';
import 'package:flutter/services.dart';

/// 已知地址标签服务 — 从本地 asset 加载，同步查询，无网络请求。
class AddressLabelService {
  AddressLabelService._();

  static Map<String, AddressLabel>? _labels;

  /// 初始化：从 assets/data/known_addresses.json 加载标签数据。
  /// 应在 app 启动时调用一次。
  static Future<void> init() async {
    if (_labels != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/known_addresses.json');
      final List<dynamic> list = jsonDecode(jsonStr);
      _labels = {
        for (final item in list)
          if (item is Map)
            (item['address'] ?? '').toString().toLowerCase():
                AddressLabel.fromJson(Map<String, dynamic>.from(item)),
      };
    } catch (_) {
      _labels = {};
    }
  }

  /// 查找地址标签，返回 null 表示未知地址。
  static AddressLabel? getLabel(String address) {
    return _labels?[address.toLowerCase()];
  }
}

class AddressLabel {
  final String name;
  final String category; // "exchange" | "bridge" | "defi" | "scam"
  final String riskLevel; // "safe" | "caution" | "danger"

  const AddressLabel({
    required this.name,
    required this.category,
    required this.riskLevel,
  });

  factory AddressLabel.fromJson(Map<String, dynamic> json) {
    return AddressLabel(
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      riskLevel: (json['risk'] ?? 'safe').toString(),
    );
  }
}
