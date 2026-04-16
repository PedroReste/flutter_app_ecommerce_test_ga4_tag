import 'dart:math';
import 'cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final String affiliation;
  final double shipping;
  final double tax;
  final String? coupon;

  const Order({
    required this.id,
    required this.items,
    required this.affiliation,
    required this.shipping,
    required this.tax,
    this.coupon,
  });

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get total => subtotal + shipping + tax;

  factory Order.create({
    required List<CartItem> items,
    String? coupon,
  }) {
    final subtotal = items.fold(0.0, (sum, i) => sum + i.subtotal);
    final shipping = subtotal > 5000 ? 0.0 : 29.90;
    final tax = subtotal * 0.05;
    final orderId =
        'ORD-${Random().nextInt(900000) + 100000}';

    return Order(
      id: orderId,
      items: List.unmodifiable(items),
      affiliation: 'TechStore Flutter App',
      shipping: shipping,
      tax: tax,
      coupon: coupon?.isEmpty == true ? null : coupon,
    );
  }
}
