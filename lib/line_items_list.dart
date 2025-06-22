import 'package:flutter/material.dart';
import 'line_item.dart';
import 'line_item_row.dart';

class LineItemsList extends StatelessWidget {
  final List<LineItem> items;
  final bool discountIsPercent;
  final ValueChanged<int> onRemove;
  final ValueChanged<MapEntry<int, LineItem>> onItemChanged;

  const LineItemsList({
    super.key,
    required this.items,
    required this.discountIsPercent,
    required this.onRemove,
    required this.onItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(items.length, (index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: LineItemRow(
              key: ObjectKey(item),
              item: item,
              discountIsPercent: discountIsPercent,
              onChanged: (newItem) => onItemChanged(MapEntry(index, newItem)),
              onRemove: () => onRemove(index),
            ),
          );
        }),
      ],
    );
  }
}
