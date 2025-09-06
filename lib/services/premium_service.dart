import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // プレミアムプランのプロダクトID（App Store Connectで設定する）
  static const String premiumSubscriptionId = 'com.example.003goals.premium_monthly';
  
  bool _isPremium = false;
  List<ProductDetails> _products = [];
  bool _isInitialized = false;
  
  bool get isPremium => _isPremium;
  List<ProductDetails> get products => _products;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (!kIsWeb) {
      try {
        // In-App Purchase が利用可能かチェック
        final bool available = await _inAppPurchase.isAvailable();
        if (!available) {
          if (kDebugMode) {
            print('In-App Purchase is not available on this device');
          }
          _isInitialized = true;
          return;
        }

        // プロダクト情報を取得
        await _loadProducts();

        // 購入状況を監視
        _subscription = _inAppPurchase.purchaseStream.listen(
          _handlePurchaseUpdates,
          onDone: () {
            if (kDebugMode) {
              print('Purchase stream closed');
            }
          },
          onError: (error) {
            if (kDebugMode) {
              print('Purchase stream error: $error');
            }
          },
        );

        // 既存の購入を復元
        await _restorePurchases();

        _isInitialized = true;
        if (kDebugMode) {
          print('PremiumService initialized successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error initializing PremiumService: $e');
        }
        _isInitialized = true; // エラーでも初期化完了とする
      }
    } else {
      // Webプラットフォームでは何もしない
      _isInitialized = true;
    }
  }

  Future<void> _loadProducts() async {
    try {
      final Set<String> productIds = {premiumSubscriptionId};
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
      
      if (response.error != null) {
        if (kDebugMode) {
          print('Error loading products: ${response.error}');
        }
        return;
      }

      _products = response.productDetails;
      if (kDebugMode) {
        print('Loaded ${_products.length} products');
        for (var product in _products) {
          print('Product: ${product.id}, Price: ${product.price}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in _loadProducts: $e');
      }
    }
  }

  Future<bool> purchasePremium() async {
    if (kIsWeb || _products.isEmpty) {
      if (kDebugMode) {
        print('Cannot purchase: Web platform or no products available');
      }
      return false;
    }

    try {
      final ProductDetails premiumProduct = _products.firstWhere(
        (product) => product.id == premiumSubscriptionId,
        orElse: () => throw Exception('Premium product not found'),
      );

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: premiumProduct);
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (kDebugMode) {
        print('Purchase initiated: $success');
      }
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error purchasing premium: $e');
      }
      return false;
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      if (kDebugMode) {
        print('Restore purchases completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring purchases: $e');
      }
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (kDebugMode) {
        print('Purchase update: ${purchaseDetails.productID}, Status: ${purchaseDetails.status}');
      }

      switch (purchaseDetails.status) {
        case PurchaseStatus.purchased:
          _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          _handlePurchaseError(purchaseDetails);
          break;
        case PurchaseStatus.pending:
          if (kDebugMode) {
            print('Purchase is pending: ${purchaseDetails.productID}');
          }
          break;
        case PurchaseStatus.canceled:
          if (kDebugMode) {
            print('Purchase was canceled: ${purchaseDetails.productID}');
          }
          break;
      }

      // 購入処理完了の確認
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    if (purchaseDetails.productID == premiumSubscriptionId) {
      _isPremium = true;
      if (kDebugMode) {
        print('Premium subscription activated');
      }
    }
  }

  void _handlePurchaseError(PurchaseDetails purchaseDetails) {
    if (kDebugMode) {
      print('Purchase error: ${purchaseDetails.error}');
    }
  }

  String getPremiumPrice() {
    if (_products.isEmpty) {
      return '¥200'; // フォールバック価格
    }
    
    try {
      final ProductDetails premiumProduct = _products.firstWhere(
        (product) => product.id == premiumSubscriptionId,
      );
      return premiumProduct.price;
    } catch (e) {
      return '¥200'; // フォールバック価格
    }
  }

  Future<bool> restorePurchases() async {
    if (kIsWeb) return false;

    try {
      await _inAppPurchase.restorePurchases();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring purchases: $e');
      }
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}