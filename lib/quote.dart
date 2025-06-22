import 'client.dart';
import 'line_item.dart';

class Quote {
  Client client;
  List<LineItem> items;
  double subtotal;
  double grandTotal;

  Quote({
    required this.client,
    required this.items,
    required this.subtotal,
    required this.grandTotal,
  });
}
