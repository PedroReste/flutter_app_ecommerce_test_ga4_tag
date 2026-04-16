import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';

/// AnalyticsManager
///
/// Singleton que centraliza todos os eventos GA4 recomendados:
/// - Eventos Gerais: screen_view, login, sign_up, search, share,
/// select_content, generate_lead, tutorial_begin,
/// tutorial_complete
/// - Eventos Ecommerce: view_item_list, select_item, view_item,
/// add_to_cart, remove_from_cart, view_cart,
/// add_to_wishlist, begin_checkout,
/// add_shipping_info, add_payment_info,
/// purchase, refund, view_promotion,
/// select_promotion
class AnalyticsManager {
  AnalyticsManager._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Observer para integração com GoRouter / Navigator
  static final FirebaseAnalyticsObserver routeObserver =
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ─────────────────────────────────────────
  // Debug helper
  // ─────────────────────────────────────────

  static void _log(String eventName, Map<String, Object?>? params) {
    if (kDebugMode) {
      debugPrint('📊 [Analytics] Event: $eventName');
      params?.forEach((key, value) {
        debugPrint(' └─ $key: $value');
      });
    }
  }

  // =========================================================
  // MARK: EVENTOS GERAIS RECOMENDADOS (GA4)
  // =========================================================

  /// screen_view
  /// Dispara quando o usuário visualiza uma tela.
  static Future<void> logScreenView({
    required String screenName,
    required String screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
    _log('screen_view', {
      'screen_name': screenName,
      'screen_class': screenClass,
    });
  }

  /// login
  /// Dispara quando o usuário faz login.
  static Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
    _log('login', {'method': method});
  }

  /// sign_up
  /// Dispara quando o usuário se cadastra.
  static Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
    _log('sign_up', {'method': method});
  }

  /// search
  /// Dispara quando o usuário realiza uma busca.
  static Future<void> logSearch({required String searchTerm}) async {
    await _analytics.logSearch(searchTerm: searchTerm);
    _log('search', {'search_term': searchTerm});
  }

  /// share
  /// Dispara quando o usuário compartilha conteúdo.
  static Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
    _log('share', {
      'content_type': contentType,
      'item_id': itemId,
      'method': method,
    });
  }

  /// select_content
  /// Dispara quando o usuário seleciona um conteúdo específico.
  static Future<void> logSelectContent({
    required String contentType,
    required String itemId,
  }) async {
    await _analytics.logSelectContent(
      contentType: contentType,
      itemId: itemId,
    );
    _log('select_content', {
      'content_type': contentType,
      'item_id': itemId,
    });
  }

  /// generate_lead
  /// Dispara quando um lead é gerado.
  static Future<void> logGenerateLead({
    String currency = 'BRL',
    required double value,
  }) async {
    await _analytics.logGenerateLead(
      currency: currency,
      value: value,
    );
    _log('generate_lead', {
      'currency': currency,
      'value': value,
    });
  }

  /// tutorial_begin
  /// Dispara quando o usuário inicia um tutorial.
  static Future<void> logTutorialBegin() async {
    await _analytics.logTutorialBegin();
    _log('tutorial_begin', null);
  }

  /// tutorial_complete
  /// Dispara quando o usuário conclui um tutorial.
  static Future<void> logTutorialComplete() async {
    await _analytics.logTutorialComplete();
    _log('tutorial_complete', null);
  }

  // =========================================================
  // MARK: EVENTOS DE ECOMMERCE (GA4)
  // =========================================================

  /// view_item_list
  /// Dispara quando uma lista de produtos é exibida.
  static Future<void> logViewItemList({
    required List<Product> items,
    required String listId,
    required String listName,
  }) async {
    final itemsArray = items.asMap().entries.map((entry) {
      return entry.value.toAnalyticsItem(
        index: entry.key,
        listId: listId,
        listName: listName,
      );
    }).toList();

    await _analytics.logViewItemList(
      itemListId: listId,
      itemListName: listName,
      items: itemsArray,
    );
    _log('view_item_list', {
      'item_list_id': listId,
      'item_list_name': listName,
      'items_count': itemsArray.length,
    });
  }

  /// select_item
  /// Dispara quando o usuário seleciona um produto da lista.
  static Future<void> logSelectItem({
    required Product product,
    required int index,
    required String listId,
    required String listName,
  }) async {
    await _analytics.logSelectItem(
      itemListId: listId,
      itemListName: listName,
      items: [
        product.toAnalyticsItem(
          index: index,
          listId: listId,
          listName: listName,
        ),
      ],
    );
    _log('select_item', {
      'item_list_id': listId,
      'item_list_name': listName,
      'item_id': product.id,
      'index': index,
    });
  }

  /// view_item
  /// Dispara quando o usuário visualiza detalhes de um produto.
  static Future<void> logViewItem({required Product product}) async {
    await _analytics.logViewItem(
      currency: 'BRL',
      value: product.price,
      items: [product.toAnalyticsItem()],
    );
    _log('view_item', {
      'currency': 'BRL',
      'value': product.price,
      'item_id': product.id,
    });
  }

  /// add_to_cart
  /// Dispara quando um produto é adicionado ao carrinho.
  static Future<void> logAddToCart({
    required Product product,
    required int quantity,
  }) async {
    await _analytics.logAddToCart(
      currency: 'BRL',
      value: product.price * quantity,
      items: [product.toAnalyticsItem(quantity: quantity)],
    );
    _log('add_to_cart', {
      'currency': 'BRL',
      'value': product.price * quantity,
      'item_id': product.id,
      'quantity': quantity,
    });
  }

  /// remove_from_cart
  /// Dispara quando um produto é removido do carrinho.
  static Future<void> logRemoveFromCart({
    required Product product,
    required int quantity,
  }) async {
    await _analytics.logRemoveFromCart(
      currency: 'BRL',
      value: product.price * quantity,
      items: [product.toAnalyticsItem(quantity: quantity)],
    );
    _log('remove_from_cart', {
      'currency': 'BRL',
      'value': product.price * quantity,
      'item_id': product.id,
      'quantity': quantity,
    });
  }

  /// view_cart
  /// Dispara quando o usuário visualiza o carrinho.
  static Future<void> logViewCart({
    required List<CartItem> cartItems,
  }) async {
    final total = cartItems.fold(
      0.0,
      (sum, item) => sum + item.subtotal,
    );
    await _analytics.logViewCart(
      currency: 'BRL',
      value: total,
      items: cartItems
          .map((i) => i.product.toAnalyticsItem(quantity: i.quantity))
          .toList(),
    );
    _log('view_cart', {
      'currency': 'BRL',
      'value': total,
      'items_count': cartItems.length,
    });
  }

  /// add_to_wishlist
  /// Dispara quando um produto é adicionado à lista de desejos.
  static Future<void> logAddToWishlist({
    required Product product,
  }) async {
    await _analytics.logAddToWishlist(
      currency: 'BRL',
      value: product.price,
      items: [product.toAnalyticsItem()],
    );
    _log('add_to_wishlist', {
      'currency': 'BRL',
      'value': product.price,
      'item_id': product.id,
    });
  }

  /// begin_checkout
  /// Dispara quando o usuário inicia o checkout.
  static Future<void> logBeginCheckout({
    required List<CartItem> cartItems,
    String? coupon,
  }) async {
    final total = cartItems.fold(
      0.0,
      (sum, item) => sum + item.subtotal,
    );
    await _analytics.logBeginCheckout(
      currency: 'BRL',
      value: total,
      coupon: coupon,
      items: cartItems
          .map((i) => i.product.toAnalyticsItem(quantity: i.quantity))
          .toList(),
    );
    _log('begin_checkout', {
      'currency': 'BRL',
      'value': total,
      if (coupon != null) 'coupon': coupon,
    });
  }

  /// add_payment_info
  /// Dispara quando o usuário adiciona informações de pagamento.
  static Future<void> logAddPaymentInfo({
    required List<CartItem> cartItems,
    required String paymentType,
    String? coupon,
  }) async {
    final total = cartItems.fold(
      0.0,
      (sum, item) => sum + item.subtotal,
    );
    await _analytics.logAddPaymentInfo(
      currency: 'BRL',
      value: total,
      paymentType: paymentType,
      coupon: coupon,
      items: cartItems
          .map((i) => i.product.toAnalyticsItem(quantity: i.quantity))
          .toList(),
    );
    _log('add_payment_info', {
      'currency': 'BRL',
      'value': total,
      'payment_type': paymentType,
      if (coupon != null) 'coupon': coupon,
    });
  }

  /// add_shipping_info
  /// Dispara quando o usuário adiciona informações de entrega.
  static Future<void> logAddShippingInfo({
    required List<CartItem> cartItems,
    required String shippingTier,
    String? coupon,
  }) async {
    final total = cartItems.fold(
      0.0,
      (sum, item) => sum + item.subtotal,
    );
    await _analytics.logAddShippingInfo(
      currency: 'BRL',
      value: total,
      shippingTier: shippingTier,
      coupon: coupon,
      items: cartItems
          .map((i) => i.product.toAnalyticsItem(quantity: i.quantity))
          .toList(),
    );
    _log('add_shipping_info', {
      'currency': 'BRL',
      'value': total,
      'shipping_tier': shippingTier,
      if (coupon != null) 'coupon': coupon,
    });
  }

  /// purchase
  /// Dispara quando a compra é finalizada com sucesso.
  static Future<void> logPurchase({required Order order}) async {
    await _analytics.logPurchase(
      transactionId: order.id,
      affiliation: order.affiliation,
      currency: 'BRL',
      value: order.total,
      tax: order.tax,
      shipping: order.shipping,
      coupon: order.coupon,
      items: order.items
          .map((i) => i.product.toAnalyticsItem(quantity: i.quantity))
          .toList(),
    );
    _log('purchase', {
      'transaction_id': order.id,
      'affiliation': order.affiliation,
      'currency': 'BRL',
      'value': order.total,
      'tax': order.tax,
      'shipping': order.shipping,
      if (order.coupon != null) 'coupon': order.coupon!,
    });
  }

  /// refund
  /// Dispara quando uma compra é reembolsada.
  static Future<void> logRefund({
    required Order order,
    List<CartItem>? partialItems,
  }) async {
    final items = partialItems ?? order.items;
    await _analytics.logRefund(
      transactionId: order.id,
      currency: 'BRL',
      value: order.total,
      items: items
          .map((i) => i.product.toAnalyticsItem(quantity: i.quantity))
          .toList(),
    );
    _log('refund', {
      'transaction_id': order.id,
      'currency': 'BRL',
      'value': order.total,
    });
  }

  /// view_promotion
  /// Dispara quando uma promoção é exibida ao usuário.
  static Future<void> logViewPromotion({
    required String promotionId,
    required String promotionName,
    required String creativeName,
    required String creativeSlot,
    required List<Product> items,
  }) async {
    await _analytics.logViewPromotion(
      promotionId: promotionId,
      promotionName: promotionName,
      creativeName: creativeName,
      creativeSlot: creativeSlot,
      items: items
          .map(
            (p) => p.toAnalyticsItem(
              promotionId: promotionId,
              promotionName: promotionName,
              creativeName: creativeName,
              creativeSlot: creativeSlot,
            ),
          )
          .toList(),
    );
    _log('view_promotion', {
      'promotion_id': promotionId,
      'promotion_name': promotionName,
      'creative_name': creativeName,
      'creative_slot': creativeSlot,
    });
  }

  /// select_promotion
  /// Dispara quando o usuário clica em uma promoção.
  static Future<void> logSelectPromotion({
    required String promotionId,
    required String promotionName,
    required String creativeName,
    required String creativeSlot,
    required List<Product> items,
  }) async {
    await _analytics.logSelectPromotion(
      promotionId: promotionId,
      promotionName: promotionName,
      creativeName: creativeName,
      creativeSlot: creativeSlot,
      items: items
          .map(
            (p) => p.toAnalyticsItem(
              promotionId: promotionId,
              promotionName: promotionName,
              creativeName: creativeName,
              creativeSlot: creativeSlot,
            ),
          )
          .toList(),
    );
    _log('select_promotion', {
      'promotion_id': promotionId,
      'promotion_name': promotionName,
      'creative_name': creativeName,
      'creative_slot': creativeSlot,
    });
  }
}
