import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'client_info_form.dart';
import 'line_items_list.dart';
import 'totals_summary.dart';
import 'calculations.dart';
import 'client.dart';
import 'line_item.dart';
import 'quote_preview_screen.dart';
import 'quote_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProductQuoteBuilderApp(prefs: prefs));
}

class ProductQuoteBuilderApp extends StatelessWidget {
  final SharedPreferences prefs;

  const ProductQuoteBuilderApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuoteProvider(prefs: prefs),
      child: MaterialApp(
        title: 'Product Quote Builder',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const QuoteFormScreen(),
        routes: {'/preview': (_) => const QuotePreviewScreen()},
      ),
    );
  }
}

class QuoteFormScreen extends StatelessWidget {
  const QuoteFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuoteProvider>(context);
    final subtotal = calculateSubtotal(
      provider.items,
      discountIsPercent: provider.discountIsPercent,
      taxMode: provider.taxMode,
    );
    final grandTotal = calculateGrandTotal(
      provider.items,
      discountIsPercent: provider.discountIsPercent,
      taxMode: provider.taxMode,
    );

    void _showAddItemDialog() {
      String productName = '';
      int quantity = 1;
      double rate = 0;
      double? discount;
      double taxPercent = 0;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add New Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: productName.isNotEmpty ? productName : null,
                    hint: const Text('Select Product/Service'),
                    items: const [
                      'Consulting',
                      'Software License',
                      'Support',
                      'Custom Development',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      productName = value ?? '';
                    },
                    decoration: const InputDecoration(labelText: 'Product/Service'),
                  ),
                  TextFormField(
                    initialValue: quantity.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    onChanged: (value) {
                      quantity = int.tryParse(value) ?? 1;
                    },
                  ),
                  TextFormField(
                    initialValue: rate.toString(),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Rate'),
                    onChanged: (value) {
                      rate = double.tryParse(value) ?? 0;
                    },
                  ),
                  TextFormField(
                    initialValue: discount?.toString() ?? '',
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Discount'),
                    onChanged: (value) {
                      discount = value.isEmpty ? null : double.tryParse(value);
                    },
                  ),
                  TextFormField(
                    initialValue: taxPercent.toString(),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Tax %'),
                    onChanged: (value) {
                      taxPercent = double.tryParse(value) ?? 0;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (productName.isNotEmpty) {
                    provider.addItem(LineItem(
                      productName: productName,
                      quantity: quantity,
                      rate: rate,
                      discount: discount,
                      taxPercent: taxPercent,
                    ));
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }

    void _showSendSimulation() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quote Sent'),
          content: const Text('Quote Sent to client@example.com'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create Quote')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClientInfoForm(
              client: provider.client,
              onChanged: provider.updateClient,
            ),
            Row(
              children: [
                const Text('Discount Type:'),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Fixed'),
                  selected: !provider.discountIsPercent,
                  onSelected: (selected) => provider.setDiscountType(false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Percent'),
                  selected: provider.discountIsPercent,
                  onSelected: (selected) => provider.setDiscountType(true),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Tax Mode:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: provider.taxMode,
                  items: const [
                    'Tax Exclusive',
                    'Tax Inclusive',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) provider.setTaxMode(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Currency:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: provider.currency,
                  items:  [
                    '₹',
                    '\$',
                    '€',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) provider.setCurrency(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (provider.items.isNotEmpty) LineItemsList(
              items: provider.items,
              discountIsPercent: provider.discountIsPercent,
              onRemove: provider.removeItem,
              onItemChanged: (entry) =>
                  provider.updateItem(entry.key, entry.value),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddItemDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
                ElevatedButton.icon(
                  onPressed: _showSendSimulation,
                  icon: const Icon(Icons.send),
                  label: const Text('Send Quote'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: provider.status,
              items: const [
                'Draft',
                'Sent',
                'Accepted',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) provider.setStatus(value);
              },
              hint: const Text('Select Status'),
            ),
            const SizedBox(height: 8),
            TotalsSummary(
              subtotal: subtotal,
              grandTotal: grandTotal,
              currency: provider.currency,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/preview');
        },
        tooltip: 'Preview Quote',
        child: const Icon(Icons.preview),
      ),
    );
  }
}