import 'package:equatable/equatable.dart';

/// Category of redemption items
enum RedemptionCategory {
  role,
  badge,
  feature,
  custom,
}

/// An item that can be redeemed with points.
class RedemptionItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final int cost;
  final RedemptionCategory category;
  final String? imageUrl;
  final int? stock;
  final bool isAvailable;

  const RedemptionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    this.category = RedemptionCategory.custom,
    this.imageUrl,
    this.stock,
    this.isAvailable = true,
  });

  /// Whether the item has stock remaining (unlimited if stock is null)
  bool get isInStock => stock == null || stock! > 0;

  /// Whether the item can be redeemed (available and in stock)
  bool get canRedeem => isAvailable && isInStock;

  @override
  List<Object?> get props => [id, name, cost, category, stock, isAvailable];
}
