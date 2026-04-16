import 'package:firebase_analytics/firebase_analytics.dart';

class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String subcategory;
  final double price;
  final double originalPrice;
  final String currency;
  final String iconName;
  final String description;
  final String variant;
  final double rating;
  final int reviewCount;
  final bool isOnSale;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.subcategory,
    required this.price,
    required this.originalPrice,
    this.currency = 'BRL',
    required this.iconName,
    required this.description,
    required this.variant,
    required this.rating,
    required this.reviewCount,
    required this.isOnSale,
  });

  double get discount =>
      originalPrice > price ? originalPrice - price : 0.0;

  double get discountPercent =>
      originalPrice > price
          ? ((originalPrice - price) / originalPrice) * 100
          : 0.0;

  /// Converte para AnalyticsEventItem do GA4
  AnalyticsEventItem toAnalyticsItem({
    int quantity = 1,
    int? index,
    String? listId,
    String? listName,
    String? promotionId,
    String? promotionName,
    String? creativeName,
    String? creativeSlot,
  }) {
    return AnalyticsEventItem(
      itemId: id,
      itemName: name,
      itemBrand: brand,
      itemCategory: category,
      itemCategory2: subcategory,
      itemVariant: variant,
      price: price,
      currency: currency,
      quantity: quantity,
      discount: discount,
      index: index,
      itemListId: listId,
      itemListName: listName,
      promotionId: promotionId,
      promotionName: promotionName,
      creativeName: creativeName,
      creativeSlot: creativeSlot,
    );
  }

  // ─────────────────────────────────────────
  // Mock Data
  // ─────────────────────────────────────────
  static const List<Product> mockProducts = [
    Product(
      id: 'SKU-001',
      name: 'iPhone 15 Pro',
      brand: 'Apple',
      category: 'Eletrônicos',
      subcategory: 'Smartphones',
      price: 7999.99,
      originalPrice: 8999.99,
      iconName: 'smartphone',
      description:
          'O iPhone mais avançado com chip A17 Pro, câmera de 48MP '
          'e design em titânio. Tela Super Retina XDR de 6.1 polegadas.',
      variant: '256GB / Titânio Natural',
      rating: 4.8,
      reviewCount: 2341,
      isOnSale: true,
    ),
    Product(
      id: 'SKU-002',
      name: 'MacBook Air M3',
      brand: 'Apple',
      category: 'Eletrônicos',
      subcategory: 'Notebooks',
      price: 12499.99,
      originalPrice: 12499.99,
      iconName: 'laptop',
      description:
          'O notebook mais fino da Apple com chip M3. '
          'Até 18 horas de bateria e tela Liquid Retina de 13.6 polegadas.',
      variant: '8GB RAM / 256GB SSD',
      rating: 4.9,
      reviewCount: 1876,
      isOnSale: false,
    ),
    Product(
      id: 'SKU-003',
      name: 'AirPods Pro 2',
      brand: 'Apple',
      category: 'Eletrônicos',
      subcategory: 'Áudio',
      price: 1799.99,
      originalPrice: 2199.99,
      iconName: 'headphones',
      description:
          'Cancelamento de ruído ativo de nível profissional. '
          'Resistente à água com case MagSafe.',
      variant: 'Branco / MagSafe',
      rating: 4.7,
      reviewCount: 4521,
      isOnSale: true,
    ),
    Product(
      id: 'SKU-004',
      name: 'Samsung Galaxy S24 Ultra',
      brand: 'Samsung',
      category: 'Eletrônicos',
      subcategory: 'Smartphones',
      price: 6999.99,
      originalPrice: 7999.99,
      iconName: 'phone_android',
      description:
          'Flagship Samsung com câmera de 200MP e S Pen integrada. '
          'Tela Dynamic AMOLED 2X de 6.8 polegadas.',
      variant: '256GB / Titânio Preto',
      rating: 4.7,
      reviewCount: 2156,
      isOnSale: true,
    ),
    Product(
      id: 'SKU-005',
      name: 'iPad Pro M4',
      brand: 'Apple',
      category: 'Eletrônicos',
      subcategory: 'Tablets',
      price: 9999.99,
      originalPrice: 9999.99,
      iconName: 'tablet',
      description:
          'O tablet mais poderoso com chip M4 e tela OLED. '
          'Compatível com Apple Pencil Pro e Magic Keyboard.',
      variant: '11 polegadas / 256GB / Wi-Fi',
      rating: 4.9,
      reviewCount: 987,
      isOnSale: false,
    ),
    Product(
      id: 'SKU-006',
      name: 'Sony WH-1000XM5',
      brand: 'Sony',
      category: 'Eletrônicos',
      subcategory: 'Áudio',
      price: 1599.99,
      originalPrice: 1999.99,
      iconName: 'headset',
      description:
          'Headphone com melhor cancelamento de ruído do mercado. '
          '30 horas de bateria e qualidade de áudio Hi-Res.',
      variant: 'Preto',
      rating: 4.8,
      reviewCount: 6789,
      isOnSale: true,
    ),
    Product(
      id: 'SKU-007',
      name: 'Apple Watch Series 9',
      brand: 'Apple',
      category: 'Eletrônicos',
      subcategory: 'Wearables',
      price: 3299.99,
      originalPrice: 3599.99,
      iconName: 'watch',
      description:
          'Smartwatch com chip S9 e gesto Double Tap. '
          'Monitor de saúde com ECG e oxímetro.',
      variant: '41mm / Meia-noite',
      rating: 4.6,
      reviewCount: 3102,
      isOnSale: true,
    ),
    Product(
      id: 'SKU-008',
      name: 'JBL Flip 6',
      brand: 'JBL',
      category: 'Eletrônicos',
      subcategory: 'Áudio',
      price: 699.99,
      originalPrice: 899.99,
      iconName: 'speaker',
      description:
          'Caixa de som portátil com som potente e graves profundos. '
          'À prova d\'água IP67 e 12 horas de bateria.',
      variant: 'Azul',
      rating: 4.7,
      reviewCount: 12543,
      isOnSale: true,
    ),
  ];
}
