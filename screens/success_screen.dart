import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../analytics/analytics_manager.dart';
import '../models/order.dart';
import '../services/cart_service.dart';
import '../services/order_repository.dart';

class SuccessScreen extends StatefulWidget {
  final String orderId;

  const SuccessScreen({super.key, required this.orderId});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  Order? _order;
  bool _purchaseLogged = false;

  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  final _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _order = context.read<OrderRepository>().getOrder(widget.orderId);

      // ✅ screen_view
      AnalyticsManager.logScreenView(
        screenName: 'compra-confirmada',
        screenClass: 'SuccessScreen',
      );

      // ✅ purchase — dispara apenas uma vez
      if (!_purchaseLogged && _order != null) {
        _purchaseLogged = true;
        AnalyticsManager.logPurchase(order: _order!);

        // Limpa carrinho após compra confirmada
        context.read<CartService>().clearCart();

        // Remove pedido do repositório
        context.read<OrderRepository>().clearOrder(widget.orderId);

        // Inicia animação de sucesso
        _animController.forward();

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedido Confirmado'),
        automaticallyImplyLeading: false,
      ),
      body: _order == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildSuccessIcon(),
                  const SizedBox(height: 20),
                  _buildSuccessTitle(),
                  const SizedBox(height: 24),
                  _buildOrderCard(),
                  const SizedBox(height: 16),
                  _buildFinancialCard(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // ─────────────────────────────────────────
  // Widgets
  // ─────────────────────────────────────────

  Widget _buildSuccessIcon() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF1AB866).withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          size: 70,
          color: Color(0xFF1AB866),
        ),
      ),
    );
  }

  Widget _buildSuccessTitle() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          const Text(
            'Compra Realizada! 🎉',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Seu pedido foi confirmado com sucesso.\nAguarde a entrega! 🚀',
            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Código do Pedido',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              _order!.id,
              style: const TextStyle(
                color: Color(0xFFFF9400),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _order!.affiliation,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Divider(height: 24, color: Color(0xFF33333F)),
            // Lista de itens
            ..._order!.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: const Color(0xFFFF9400).withOpacity(0.7),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Qtd: ${item.quantity}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _currencyFormatter.format(item.subtotal),
                      style: const TextStyle(
                        color: Color(0xFFFF9400),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFinancialRow('Subtotal', _order!.subtotal),
            const SizedBox(height: 8),
            _buildFinancialRow(
              'Frete',
              _order!.shipping,
              valueWidget: _order!.shipping == 0
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
            _buildFinancialRow('Impostos (5%)', _order!.tax),
            if (_order!.coupon != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1AB866).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '🏷️ Cupom aplicado: ${_order!.coupon}',
                  style: const TextStyle(
                    color: Color(0xFF1AB866),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const Divider(height: 20, color: Color(0xFF33333F)),
            _buildFinancialRow('Total Pago', _order!.total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(
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
            fontSize: isTotal ? 17 : 14,
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Continuar Comprando
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Continuar Comprando'),
            onPressed: () {
              // ✅ select_content
              AnalyticsManager.logSelectContent(
                contentType: 'navigation',
                itemId: 'continue-shopping',
              );
              context.go('/home');
            },
          ),
        ),
        const SizedBox(height: 12),

        // Compartilhar Pedido
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            icon: const Icon(
              Icons.share,
              color: Color(0xFF4D80FF),
            ),
            label: const Text(
              'Compartilhar Pedido',
              style: TextStyle(color: Color(0xFF4D80FF)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF4D80FF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _shareOrder,
          ),
        ),
        const SizedBox(height: 12),

        // Solicitar Reembolso
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            icon: const Icon(
              Icons.undo_rounded,
              color: Colors.red,
            ),
            label: const Text(
              'Solicitar Reembolso',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _requestRefund,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────

  void _shareOrder() {
    // ✅ share
    AnalyticsManager.logShare(
      contentType: 'order',
      itemId: _order!.id,
      method: 'flutter-share-sheet',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🛍️ Pedido ${_order!.id} — '
          'Total: ${_currencyFormatter.format(_order!.total)}',
        ),
      ),
    );
  }

  void _requestRefund() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF242430),
        title: const Text(
          'Solicitar Reembolso',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Deseja solicitar reembolso do pedido ${_order!.id}?\n'
          'Total: ${_currencyFormatter.format(_order!.total)}',
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

              // ✅ refund
              AnalyticsManager.logRefund(order: _order!);

              showDialog<void>(
                context: context,
                builder: (ctx2) => AlertDialog(
                  backgroundColor: const Color(0xFF242430),
                  title: const Text(
                    '✅ Reembolso Solicitado',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Seu reembolso será processado em até 5 dias úteis.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx2).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
