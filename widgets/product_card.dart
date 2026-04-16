import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem + badge
              Stack(
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A21),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _iconFromName(product.iconName),
                      size: 44,
                      color: const Color(0xFFFF9400),
                    ),
                  ),
                  if (product.isOnSale)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercent.toInt()}%',
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
              const SizedBox(height: 10),

              // Nome
              Text(
                product.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // Marca
              Text(
                product.brand,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),

              // Rating
              Text(
                '⭐ ${product.rating} (${product.reviewCount})',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),

              // Preço
              Text(
                currencyFormatter.format(product.price),
                style: const TextStyle(
                  color: Color(0xFFFF9400),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Preço original com tachado
              if (product.isOnSale) ...[
                const SizedBox(height: 2),
                Text(
                  currencyFormatter.format(product.originalPrice),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.grey,
                  ),
                ),
              ] else
                const SizedBox(height: 14),

              const SizedBox(height: 10),

              // Botão Adicionar
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label: const Text(
                    'Adicionar',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: onAddToCart,
                ),
              ),
            ],
          ),
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
