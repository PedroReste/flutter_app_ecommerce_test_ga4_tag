import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../analytics/analytics_manager.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class ProductScreen extends StatefulWidget {
  final String productId;
  final String listId;
  final String listName;
  final int index;

  const ProductScreen({
    super.key,
    required this.productId,
    required this.listId,
    required this.listName,
    required this.index,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Product _product;
  int _quantity = 1;
  bool _isWishlisted = false;
  bool _addedToCart = false;

  final _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  void initState() {
    super.initState();
    _product = Product.mockProducts.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => Product.mockProducts.first,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ screen_view
      AnalyticsManager.logScreenView(
        screenName: 'produto-detalhe',
        screenClass: 'ProductScreen',
      );

      // ✅ view_item
      AnalyticsManager.logViewItem(product: _product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: _isWishlisted ? Colors.red : null,
            ),
            onPressed: _toggleWishlist,
            tooltip: 'Favoritar',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProduct,
            tooltip: 'Compartilhar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBrandAndCategory(),
                  const SizedBox(height: 8),
                  _buildProductName(),
                  const SizedBox(height: 4),
                  _buildVariant(),
                  const SizedBox(height: 12),
                  _buildRating(),
                  const SizedBox(height: 16),
                  _buildPrices(),
                  const Divider(height: 32, color: Color(0xFF33333F)),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildQuantitySelector(),
                  const SizedBox(height: 24),
                  _buildAddToCartButton(),
                  const SizedBox(height: 12),
                  _buildSecondaryActions(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Widgets
  // ─────────────────────────────────────────

  Widget _buildProductImage() {
    return Container(
      height: 220,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF242430),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            _iconFromName(_product.iconName),
            size: 80,
            color: const Color(0xFFFF9400),
          ),
          if (_product.isOnSale)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '-${_product.discountPercent.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBrandAndCategory() {
    return Row(
      children: [
        Text(
          _product.brand,
          style: const TextStyle(
            color: Color(0xFFFF9400),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _product.category,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildProductName() {
    return Text(
      _product.name,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildVariant() {
    return Text(
      _product.variant,
      style: const TextStyle(color: Colors.grey, fontSize: 13),
    );
  }

  Widget _buildRating() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF242430),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '⭐ ${_product.rating} · ${_product.reviewCount} avaliações',
        style: const TextStyle(
          color: Color(0xFFFFD700),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildPrices() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _currencyFormatter.format(_product.price),
          style: const TextStyle(
            color: Color(0xFFFF9400),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_product.isOnSale) ...[
          const SizedBox(width: 12),
          Text(
            _currencyFormatter.format(_product.originalPrice),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descrição',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _product.description,
          style: const TextStyle(
            color: Color(0xFFBBBBCC),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantidade',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _QuantityButton(
              icon: Icons.remove,
              onPressed: _quantity > 1
                  ? () => setState(() => _quantity--)
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              '$_quantity',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            _QuantityButton(
              icon: Icons.add,
              onPressed: _quantity < 10
                  ? () => setState(() => _quantity++)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        icon: Icon(
          _addedToCart ? Icons.check : Icons.add_shopping_cart,
        ),
        label: Text(_addedToCart ? 'Adicionado!' : 'Adicionar ao Carrinho'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _addedToCart
              ? Colors.green
              : const Color(0xFFFF9400),
        ),
        onPressed: _addToCart,
      ),
    );
  }

  Widget _buildSecondaryActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(
              _isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            label: Text(
              _isWishlisted ? 'Salvo' : 'Favoritar',
              style: const TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _toggleWishlist,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(
              Icons.share,
              color: Color(0xFF4D80FF),
            ),
            label: const Text(
              'Compartilhar',
              style: TextStyle(color: Color(0xFF4D80FF)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF4D80FF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _shareProduct,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────

  void _addToCart() {
    context.read<CartService>().addProduct(_product, quantity: _quantity);

    // ✅ add_to_cart
    AnalyticsManager.logAddToCart(
      product: _product,
      quantity: _quantity,
    );

    setState(() => _addedToCart = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _addedToCart = false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_product.name} adicionado ao carrinho!'),
        action: SnackBarAction(
          label: 'Ver Carrinho',
          onPressed: () {
            AnalyticsManager.logViewCart(
              cartItems: context.read<CartService>().items,
            );
            context.push('/cart');
          },
        ),
      ),
    );
  }

  void _toggleWishlist() {
    setState(() => _isWishlisted = !_isWishlisted);

    if (_isWishlisted) {
      // ✅ add_to_wishlist
      AnalyticsManager.logAddToWishlist(product: _product);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❤️ Adicionado aos favoritos!')),
      );
    }
  }

  void _shareProduct() {
    // ✅ share
    AnalyticsManager.logShare(
      contentType: 'product',
      itemId: _product.id,
      method: 'flutter-share-sheet',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Compartilhando: ${_product.name}',
        ),
      ),
    );
  }

  IconData _iconFromName(String name) {
    const map = {
      'smartphone': Icons.smartphone,
      'laptop': Icons.laptop,
      'headphones': Icons.headphones,
      'headset': Icons.headset,
      'tablet': Icons.tablet,
      'watch': Icons.watch,
      'speaker': Icons.speaker,
      'phone_android': Icons.phone_android,
    };
    return map[name] ?? Icons.devices;
  }
}

// ─────────────────────────────────────────
// Quantity Button Widget
// ─────────────────────────────────────────
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(
            color: onPressed != null
                ? const Color(0xFFFF9400)
                : Colors.grey,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onPressed != null
              ? const Color(0xFFFF9400)
              : Colors.grey,
        ),
      ),
    );
  }
}
