import 'package:uuid/uuid.dart';

class LineItem {
  final String id;
  String productName;
  int quantity;
  double rate;
  double? discount; // Can be percentage or fixed, to be handled in logic
  double taxPercent;

  LineItem({
    String? id,
    required this.productName,
    required this.quantity,
    required this.rate,
    this.discount,
    required this.taxPercent,
  }) : id = id ?? const Uuid().v4();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
