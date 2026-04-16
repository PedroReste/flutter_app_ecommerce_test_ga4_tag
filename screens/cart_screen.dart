import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../analytics/analytics_manager.dart';
import '../models/order.dart';
import '../services/cart_service.dart';
import '../services/order_repository.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();

  final _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = context.read<CartService>();

      // ✅ screen_view
      AnalyticsManager.logScreenView(
        screenName: 'carrinho',
        screenClass: 'CartScreen',
      );

      // ✅ view_cart
      AnalyticsManager.logViewCart(cartItems: cart.items);
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: cart.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(child: _buildCartList(cart)),
                _buildSummaryCard(cart),
              ],
            ),
    );
  }

  // ─────────────────────────────────────────
  // Widgets
  // ─────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Seu carrinho está vazio',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione produtos para continuar',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(CartService cart) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return CartItemTile(
          cartItem: item,
          onDecrease: () {
            final oldQty = item.quantity;
            final newQty = oldQty - 1;

            if (newQty <= 0) {
              _showRemoveDialog(item.product.name, () {
                // ✅ remove_from_cart
                AnalyticsManager.logRemoveFromCart(
                  product: item.product,
                  quantity: oldQty,
                );
                cart.removeProduct(item.product);
              });
            } else {
              // ✅ remove_from_cart (redução de quantidade)
              AnalyticsManager.logRemoveFromCart(
                product: item.product,
                quantity: 1,
              );
              cart.updateQuantity(item.product, newQty);
            }
          },
          onIncrease: () {
            // ✅ add_to_cart (aumento de quantidade)
            AnalyticsManager.logAddToCart(
              product: item.product,
              quantity: 1,
            );
            cart.updateQuantity(item.product, item.quantity + 1);
          },
          onRemove: () {
            _showRemoveDialog(item.product.name, () {
              // ✅ remove_from_cart
              AnalyticsManager.logRemoveFromCart(
                product: item.product,
                quantity: item.quantity,
              );
              cart.removeProduct(item.product);
            });
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(CartService cart) {
    final subtotal = cart.totalValue;
    final shipping = subtotal > 5000 ? 0.0 : 29.90;
    final tax = subtotal * 0.05;
    final total = subtotal + shipping + tax;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF242430),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow('Subtotal', subtotal),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Frete',
            shipping,
            valueWidget: shipping == 0
                ? const Text(
                    'Grátis ✅',
                    style: TextStyle(
                      color: Color(0xFF1AB866),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow('Impostos (5%)', tax),
          const Divider(height: 20, color: Color(0xFF33333F)),
          _buildSummaryRow('Total', total, isTotal: true),
          const SizedBox(height: 14),
          // Campo de cupom
          TextField(
            controller: _couponController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: 'Cupom de desconto',
              prefixIcon: Icon(
                Icons.local_offer_outlined,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Botão Finalizar Compra
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.lock_outline),
              label: const Text('Finalizar Compra'),
              onPressed: cart.isEmpty ? null : () => _checkout(cart),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String title,
    double value, {
    bool isTotal = false,
    Widget? valueWidget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.grey,
            fontSize: isTotal ? 18 : 14,
            fontWeight:
                isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        valueWidget ??
            Text(
              _currencyFormatter.format(value),
              style: TextStyle(
                color: isTotal
                    ? const Color(0xFFFF9400)
                    : Colors.white,
                fontSize: isTotal ? 20 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────

  void _checkout(CartService cart) {
    final coupon = _couponController.text.isEmpty
        ? null
        : _couponController.text;

    // ✅ add_shipping_info
    AnalyticsManager.logAddShippingInfo(
      cartItems: cart.items,
      shippingTier: 'standard',
      coupon: coupon,
    );

    // ✅ add_payment_info
    AnalyticsManager.logAddPaymentInfo(
      cartItems: cart.items,
      paymentType: 'credit_card',
      coupon: coupon,
    );

    // ✅ begin_checkout
    AnalyticsManager.logBeginCheckout(
      cartItems: cart.items,
      coupon: coupon,
    );

    // Criar pedido e salvar no repositório
    final order = Order.create(
      items: cart.items,
      coupon: coupon,
    );

    context.read<OrderRepository>().saveOrder(order);

    context.push('/success/${order.id}');
  }

  void _showRemoveDialog(String productName, VoidCallback onConfirm) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF242430),
        title: const Text(
          'Remover produto',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Deseja remover "$productName" do carrinho?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
