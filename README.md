# 🛍️ EcommerceTaggingApp — Flutter

Protótipo Flutter de e-commerce para validação de tagueamento
com **Firebase Analytics / GA4**.
Desenvolvido com Flutter + GoRouter + Provider.

---

## 📱 Telas

| Tela | Widget            | Descrição                                        |
|------|-------------------|--------------------------------------------------|
| A    | HomeScreen        | Grid de produtos, banner promoção, busca         |
| B    | ProductScreen     | Detalhes do produto, wishlist, share, quantidade |
| C    | CartScreen        | Resumo do carrinho, cupom, checkout              |
| D    | SuccessScreen     | Confirmação da compra, reembolso, share          |

---

## 📊 Eventos Firebase Analytics Implementados

### Eventos Gerais

| Evento              | Tela  | Trigger                                    |
|---------------------|-------|--------------------------------------------|
| `screen_view`       | Todas | didChangeDependencies + postFrameCallback  |
| `login`             | —     | AnalyticsManager disponível                |
| `sign_up`           | —     | AnalyticsManager disponível                |
| `search`            | A     | TextField.onSubmitted                      |
| `share`             | B, D  | Botão compartilhar                         |
| `select_content`    | D     | Botão "Continuar Comprando"                |
| `generate_lead`     | —     | AnalyticsManager disponível                |
| `tutorial_begin`    | —     | AnalyticsManager disponível                |
| `tutorial_complete` | —     | AnalyticsManager disponível                |

### Eventos de Ecommerce

| Evento               | Tela    | Trigger                                       |
|----------------------|---------|-----------------------------------------------|
| `view_item_list`     | A       | didChangeDependencies — lista visível         |
| `select_item`        | A       | GestureDetector.onTap no ProductCard          |
| `view_item`          | A, B    | onTap (A) + didChangeDependencies (B)         |
| `add_to_cart`        | A, B, C | Botão "Adicionar" / aumento de quantidade     |
| `remove_from_cart`   | C       | Dismissible / dialog confirmar / qty → 0      |
| `view_cart`          | A, C    | IconButton carrinho (A) / didChangeDeps (C)   |
| `add_to_wishlist`    | B       | IconButton coração                            |
| `begin_checkout`     | C       | ElevatedButton "Finalizar Compra"             |
| `add_shipping_info`  | C       | ElevatedButton "Finalizar Compra"             |
| `add_payment_info`   | C       | ElevatedButton "Finalizar Compra"             |
| `purchase`           | D       | didChangeDependencies — uma única vez         |
| `refund`             | D       | AlertDialog confirmar reembolso               |
| `view_promotion`     | A       | didChangeDependencies — banner visível        |
| `select_promotion`   | A       | GestureDetector.onTap no banner               |

---

## 🏗️ Arquitetura

``` Flutter + GoRouter + Provider ├── main.dart → Inicializa Firebase, Provider, GoRouter ├── AnalyticsManager → Classe estática centraliza todos eventos GA4 ├── CartService → ChangeNotifier gerencia estado do carrinho ├── OrderRepository → Armazena pedido em memória entre telas ├── Models → Product, CartItem, Order (imutáveis) ├── Screens → Uma por tela (A, B, C, D) └── Widgets → ProductCard, CartItemTile (reutilizáveis) ```

---

## 🚀 Como configurar

### 1. Pré-requisitos

```bash # Instalar Flutter SDK 3.x+ # https://flutter.dev/docs/get-started/install # Instalar FlutterFire CLI dart pub global activate flutterfire_cli ```

### 2. Clonar e instalar dependências

```bash git clone https://github.com/seu-usuario/ecommerce_tagging_app.git cd ecommerce_tagging_app flutter pub get ```

### 3. Configurar Firebase

```bash # Login no Firebase firebase login # Configurar projeto (gera firebase_options.dart automaticamente) flutterfire configure ```

### 4. Habilitar Debug Analytics

**Android:**
```bash adb shell setprop debug.firebase.analytics.app \ com.example.ecommerce_tagging_app # Ver logs detalhados adb shell setprop log.tag.FA VERBOSE adb shell setprop log.tag.FA-SVC VERBOSE ```

**iOS (Simulator):**
```bash xcrun simctl spawn booted defaults write \ com.example.ecommerce_tagging_app \ /google/measurement/debug_mode 1 ```

**Ou via Scheme Arguments (iOS):**
``` -FIRAnalyticsDebugEnabled ```

### 5. Rodar o app

```bash flutter run ```

### 6. Filtrar logs no terminal

``` 📊 [Analytics] Event: view_item_list └─ item_list_id: home-product-list └─ item_list_name: Home - Produtos em Destaque └─ items_count: 8 📊 [Analytics] Event: purchase └─ transaction_id: ORD-482910 └─ value: 8829.88 └─ currency: BRL └─ tax: 349.99 └─ shipping: 0.0 ```

---

## ⚠️ Arquivos não versionados

``` lib/firebase_options.dart android/app/google-services.json ios/Runner/GoogleService-Info.plist ```

Execute `flutterfire configure` para gerá-los localmente.

---

## 🧪 Fluxo de teste completo

``` 1. Abrir o app → screen_view (home) → view_item_list → view_promotion 2. Buscar "Samsung" e pressionar Enter → search 3. Tap no banner de promoção → select_promotion 4. Tap no card de produto → select_item → view_item → screen_view (produto-detalhe) 5. Adicionar à wishlist → add_to_wishlist 6. Alterar quantidade e adicionar ao carrinho → add_to_cart 7. Snackbar "Ver Carrinho" ou ícone do carrinho → view_cart → screen_view (carrinho) 8. Aumentar quantidade no carrinho → add_to_cart 9. Diminuir quantidade até 0 → confirmar dialog → remove_from_cart 10. Swipe no item → confirmar dialog → remove_from_cart 11. Digitar cupom e tap "Finalizar Compra" → add_shipping_info → add_payment_info → begin_checkout → screen_view (compra-confirmada) → purchase 12. Tap "Solicitar Reembolso" → confirmar → refund 13. Tap "Compartilhar Pedido" → share 14. Tap "Continuar Comprando" → select_content → (volta para Home) ```

---

## 📦 Dependências principais

| Pacote               | Versão   | Uso                          |
|----------------------|----------|------------------------------|
| `firebase_analytics` | ^11.3.3  | Coleta de eventos GA4        |
| `firebase_core`      | ^3.6.0   | Inicialização do Firebase    |
| `go_router`          | ^14.3.0  | Navegação declarativa        |
| `provider`           | ^6.1.2   | Gerenciamento de estado      |
| `intl`               | ^0.19.0  | Formatação de moeda          |
| `uuid`               | ^4.4.2   | Geração de IDs únicos        |
