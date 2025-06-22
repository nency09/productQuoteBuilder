import 'line_item.dart';

double calculateItemTotal(LineItem item, {bool discountIsPercent = false, String taxMode = 'Tax Exclusive'}) {
  double discount = item.discount ?? 0;
  double effectiveRate = item.rate;
  if (discountIsPercent) {
    effectiveRate -= (item.rate * discount / 100);
  } else {
    effectiveRate -= discount;
  }
  double baseTotal = effectiveRate * item.quantity;
  double taxAmount = baseTotal * (item.taxPercent / 100);
  if (taxMode == 'Tax Inclusive') {
    return baseTotal; // Tax is already included, adjust logic if needed
  }
  return baseTotal + taxAmount;
}

double calculateSubtotal(List<LineItem> items, {bool discountIsPercent = false, String taxMode = 'Tax Exclusive'}) {
  double subtotal = 0;
  for (var item in items) {
    double discount = item.discount ?? 0;
    double effectiveRate = item.rate;
    if (discountIsPercent) {
      effectiveRate -= (item.rate * discount / 100);
    } else {
      effectiveRate -= discount;
    }
    subtotal += effectiveRate * item.quantity;
  }
  return subtotal;
}

double calculateGrandTotal(List<LineItem> items, {bool discountIsPercent = false, String taxMode = 'Tax Exclusive'}) {
  double total = 0;
  for (var item in items) {
    total += calculateItemTotal(item, discountIsPercent: discountIsPercent, taxMode: taxMode);
  }
  return total;
}