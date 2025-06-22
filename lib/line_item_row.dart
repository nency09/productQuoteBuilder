import 'package:flutter/material.dart';
import 'line_item.dart';

class LineItemRow extends StatefulWidget {
  final LineItem item;
  final ValueChanged<LineItem> onChanged;
  final VoidCallback onRemove;
  final bool discountIsPercent;

  const LineItemRow({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onRemove,
    required this.discountIsPercent,
  });

  @override
  State<LineItemRow> createState() => _LineItemRowState();
}

class _LineItemRowState extends State<LineItemRow> {
  static const List<String> productOptions = [
    'Consulting',
    'Software License',
    'Support',
    'Custom Development',
  ];
  late String selectedProduct;
  late TextEditingController productController;
  late TextEditingController quantityController;
  late TextEditingController rateController;
  late TextEditingController discountController;
  late TextEditingController taxController;

  @override
  void initState() {
    super.initState();
    _updateControllers(widget.item);
  }

  @override
  void didUpdateWidget(LineItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item != oldWidget.item) {
      _updateControllers(widget.item);
    }
  }

  void _updateControllers(LineItem item) {
    selectedProduct = item.productName.isNotEmpty
        ? item.productName
        : productOptions.first;
    productController = TextEditingController(text: selectedProduct);
    quantityController = TextEditingController(text: item.quantity.toString());
    rateController = TextEditingController(text: item.rate.toString());
    discountController = TextEditingController(
      text: item.discount?.toString() ?? '',
    );
    taxController = TextEditingController(text: item.taxPercent.toString());
  }

  void _onChanged() {
    widget.onChanged(
      LineItem(
        productName: selectedProduct,
        quantity: int.tryParse(quantityController.text) ?? 1,
        rate: double.tryParse(rateController.text) ?? 0,
        discount: discountController.text.isEmpty
            ? null
            : double.tryParse(discountController.text),
        taxPercent: double.tryParse(taxController.text) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedProduct,
                    items: productOptions
                        .map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(
                              option,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedProduct = value;
                        });
                        _onChanged();
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Product/Service',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onRemove,
                  tooltip: 'Remove',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(left: 12.0),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Qty'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _onChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: rateController,
                    decoration: const InputDecoration(labelText: 'Rate'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _onChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: discountController,
                    decoration: InputDecoration(
                      labelText: widget.discountIsPercent
                          ? 'Discount %'
                          : 'Discount',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _onChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: taxController,
                    decoration: const InputDecoration(labelText: 'Tax %'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _onChanged(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
