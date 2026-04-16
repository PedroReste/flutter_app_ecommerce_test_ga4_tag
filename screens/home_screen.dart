import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../analytics/analytics_manager.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _listId = 'home-product-list';
  static const String _listName = 'Home - Produtos em Destaque';

  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = Product.mockProducts;
  bool _hasLoggedListView = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoggedListView) {
      _hasLoggedListView = true;
      // Disparado após o primeiro frame para garantir contexto
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _logScreenEvents();
      });
    }
  }

  void _logScreenEvents() {
    // ✅ screen_view
    AnalyticsManager.logScreenView(
      screenName: 'home',
      screenClass: 'HomeScreen',
    );

    // ✅ view_item_list
    AnalyticsManager.logViewItemList(
      items: Product.mockProducts,
      listId: _listId,
      listName: _listName,
    );

    // ✅ view_promotion — banner visível
    AnalyticsManager.logViewPromotion(
      promotionId: 'PROMO-SALE-30',
      promotionName: 'Super Sale 30% OFF',
      creativeName: 'banner-home-sale',
      creativeSlot: 'home-top-banner',
      items: Product.mockProducts.take(3).toList(),
    );
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = query.isEmpty
          ? Product.mockProducts
          : Product.mockProducts
              .where(
                (p) =>
                    p.name.toLowerCase().contains(query) ||
                    p.brand.toLowerCase().contains(query) ||
                    p.category.toLowerCase().contains(query),
              )
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛍️ TechStore'),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                tooltip: 'Carrinho',
                onPressed: () {
                  // ✅ view_cart ao abrir o carrinho
                  AnalyticsManager.logViewCart(
                    cartItems: cart.items,
                  );
                  context.push('/cart');
                },
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.totalItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildPromotionBanner(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Widgets
  // ─────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar produtos...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
        onSubmitted: (term) {
          if (term.isNotEmpty) {
            // ✅ search
            AnalyticsManager.logSearch(searchTerm: term);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('🔍 Buscando por: "$term"')),
            );
          }
        },
      ),
    );
  }

  Widget _buildPromotionBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () {
          // ✅ select_promotion
          AnalyticsManager.logSelectPromotion(
            promotionId: 'PROMO-SALE-30',
            promotionName: 'Super Sale 30% OFF',
            creativeName: 'banner-home-sale',
            creativeSlot: 'home-top-banner',
            items: Product.mockProducts.take(3).toList(),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔥 Super Sale! Até 30% OFF!'),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔥 SUPER SALE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Até 30% OFF em Eletrônicos!',
                style: TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // ✅ select_promotion
                  AnalyticsManager.logSelectPromotion(
                    promotionId: 'PROMO-SALE-30',
                    promotionName: 'Super Sale 30% OFF',
                    creativeName: 'banner-home-sale',
                    creativeSlot: 'home-top-banner',
                    items: Product.mockProducts.take(3).toList(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9400),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'Ver Ofertas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum produto encontrado 🔍',
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.58,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductCard(
          product: product,
          onTap: () {
            // ✅ select_item
            AnalyticsManager.logSelectItem(
              product: product,
              index: index,
              listId: _listId,
              listName: _listName,
            );

            // ✅ view_item (antecipado)
            AnalyticsManager.logViewItem(product: product);

            context.push(
              '/product/${product.id}',
              extra: {
                'listId': _listId,
                'listName': _listName,
                'index': index,
              },
            );
          },
          onAddToCart: () {
            // ✅ add_to_cart
            context.read<CartService>().addProduct(product);
            AnalyticsManager.logAddToCart(
              product: product,
              quantity: 1,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${product.name} adicionado!'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }
}
