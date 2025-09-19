import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  static const abiturReviewProductId = "abitur_review";
  static const fullVersionProductId = "full_version";

  static final InAppPurchase _iap = InAppPurchase.instance;

  static List<ProductDetails> _products = [];
  static List<ProductDetails> get products => _products;
  static List<PurchaseDetails> _purchases = [];

  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Für Google-Mitarbeiter: Schalter für erzwungenen Vollzugriff
  static bool _reviewMode = false;
  static bool get reviewMode => _reviewMode;

  static Future<void> init() async {
    final available = await _iap.isAvailable();
    debugPrint("Ist der Purchase-Service erreichbar? -> $available");
    if (!available) return;

    _subscription = _iap.purchaseStream.listen((purchases) {
      _purchases = purchases;
    });

    await _loadProducts();
    await _restorePurchases();
  }

  static Future<void> dispose() async {
    await _subscription?.cancel();
  }

  static Future<void> _loadProducts() async {
    final ids = {abiturReviewProductId, fullVersionProductId};
    final response = await _iap.queryProductDetails(ids);
    _products = response.productDetails;
  }

  static Future<void> _restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// Zugriff auf Kaufstatus
  static bool get abiturReviewAccess {
    if (_reviewMode || fullAccess) return true;
    return _purchases.any((p) =>
    p.productID == abiturReviewProductId &&
        p.status == PurchaseStatus.purchased);
  }

  static bool get fullAccess {
    if (_reviewMode) return true;
    return _purchases.any((p) =>
    p.productID == fullVersionProductId &&
        p.status == PurchaseStatus.purchased);
  }

  static Future<void> buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  static void activateReviewMode() {
    _reviewMode = true;
  }

  static void deactivateReviewMode() {
    _reviewMode = false;
  }
}
