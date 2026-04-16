import '../models/order.dart';

/// OrderRepository — armazena pedidos em memória
/// para transferência entre CartScreen → SuccessScreen.
class OrderRepository {
  final Map<String, Order> _orders = {};

  void saveOrder(Order order) => _orders[order.id] = order;

  Order? getOrder(String orderId) => _orders[orderId];

  void clearOrder(String orderId) => _orders.remove(orderId);
}
