import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'quote_provider.dart';
import 'client.dart';
import 'line_item.dart';
import 'calculations.dart';

class QuotePreviewScreen extends StatelessWidget {
  const QuotePreviewScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quote Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Print functionality coming soon!'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(provider.client, provider.status),
            const SizedBox(height: 24),
            _buildItemsTable(provider.items, provider.discountIsPercent, provider.currency),
            const SizedBox(height: 24),
            _buildTotals(subtotal, grandTotal, provider.currency),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Client client, String status) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'QUOTE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Client: ${client.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (client.address.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Address: ${client.address}'),
            ],
            if (client.referenceNumber != null) ...[
              const SizedBox(height: 8),
              Text('Reference: ${client.referenceNumber}'),
            ],
            const SizedBox(height: 8),
            Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
            const SizedBox(height: 8),
            Text('Status: $status', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTable(List<LineItem> items, bool discountIsPercent, String currency) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Text('No items added yet.')
            else
              Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                },
                children: [
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Product',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Qty',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Rate',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Discount',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  ...items.map((item) {
                    final itemTotal = calculateItemTotal(
                      item,
                      discountIsPercent: discountIsPercent,
                      taxMode: 'Tax Exclusive', 
                    );
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item.productName),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item.quantity.toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('$currency${item.rate.toStringAsFixed(2)}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item.discount != null
                                ? '${item.discount}${discountIsPercent ? '%' : '$currency'}'
                                : '-',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('$currency${itemTotal.toStringAsFixed(2)}'),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotals(double subtotal, double grandTotal, String currency) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                Text(
                  '$currency${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grand Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$currency${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
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