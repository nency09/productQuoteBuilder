import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'client.dart';
import 'line_item.dart';

class QuoteProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  Client client = Client(name: '', address: '', referenceNumber: null);
  List<LineItem> items = [];
  bool discountIsPercent = false;
  String taxMode = 'Tax Exclusive';
  String currency = '₹';
  String status = 'Draft';

  QuoteProvider({required this.prefs}) {
    _loadSavedData();
  }

  void _loadSavedData() {
    client.name = prefs.getString('client_name') ?? '';
    client.address = prefs.getString('client_address') ?? '';
    client.referenceNumber = prefs.getString('client_referenceNumber');
    discountIsPercent = prefs.getBool('discountIsPercent') ?? false;
    taxMode = prefs.getString('taxMode') ?? 'Tax Exclusive';
    currency = prefs.getString('currency') ?? '₹';
    status = prefs.getString('status') ?? 'Draft';
    final savedItems = prefs.getStringList('items') ?? [];
    items = savedItems.map((json) {
      final parts = json.split('|');
      return LineItem(
        productName: parts[0],
        quantity: int.parse(parts[1]),
        rate: double.parse(parts[2]),
        discount: parts[3].isEmpty ? null : double.parse(parts[3]),
        taxPercent: double.parse(parts[4]),
      );
    }).toList();
    notifyListeners();
  }

  void _saveData() {
    prefs.setString('client_name', client.name);
    prefs.setString('client_address', client.address);
    prefs.setString('client_referenceNumber', client.referenceNumber ?? '');
    prefs.setBool('discountIsPercent', discountIsPercent);
    prefs.setString('taxMode', taxMode);
    prefs.setString('currency', currency);
    prefs.setString('status', status);
    final savedItems = items.map((item) =>
        '${item.productName}|${item.quantity}|${item.rate}|${item.discount ?? ''}|${item.taxPercent}').toList();
    prefs.setStringList('items', savedItems);
  }

  void updateClient(Client newClient) {
    client = newClient;
    _saveData();
    notifyListeners();
  }

  void addItem(LineItem item) {
    items.add(item);
    _saveData();
    notifyListeners();
  }

  void updateItem(int index, LineItem item) {
    items[index] = item;
    _saveData();
    notifyListeners();
  }

  void removeItem(int index) {
    items.removeAt(index);
    _saveData();
    notifyListeners();
  }

  void setDiscountType(bool isPercent) {
    discountIsPercent = isPercent;
    _saveData();
    notifyListeners();
  }

  void setTaxMode(String mode) {
    taxMode = mode;
    _saveData();
    notifyListeners();
  }

  void setCurrency(String curr) {
    currency = curr;
    _saveData();
    notifyListeners();
  }

  void setStatus(String stat) {
    status = stat;
    _saveData();
    notifyListeners();
  }
}