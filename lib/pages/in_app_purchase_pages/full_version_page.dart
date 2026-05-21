import 'dart:async';

import 'package:abitur/widgets/product_features/product_action_area.dart';
import 'package:abitur/widgets/product_features/product_button.dart';
import 'package:abitur/widgets/product_features/product_feature_badge.dart';
import 'package:abitur/widgets/product_features/product_title.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../in_app_purchases/purchase_service.dart';
import '../../widgets/product_features/product_feature.dart';

class FullVersionPage extends StatefulWidget {

  final Widget nextPage;

  const FullVersionPage({super.key, required this.nextPage});

  @override
  State<FullVersionPage> createState() => _FullVersionPageState();
}

class _FullVersionPageState extends State<FullVersionPage> {

  late final ProductDetails? product;

  bool purchaseInProgress = false;

  @override
  void initState() {

    product = PurchaseService.products
        .where((p) => p.id == PurchaseService.fullVersionProductId)
        .firstOrNull;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const ProductTitle(
                "Schalte mehr Features frei.",
              ),

              ProductFeature(
                icon: Icons.calendar_month,
                title: "Kalendersynchronisierung",
                subtitle: "Synchronisiere Prüfungen bestimmter Typen und Events mit deinem Geräte-Kalender",
              ),
              ProductFeature(
                icon: Icons.widgets,
                title: "Widgets",
                badge: ProductFeatureBadge.comingSoon,
                subtitle: "Platziere Widgets auf deinem Homescreen",
              ),
              ProductFeature(
                icon: Icons.query_stats,
                title: "Analysen",
                subtitle: "Profitiere von zusätzlichen Statistiken",
              ),
              ProductFeature(
                icon: Icons.star,
                title: "Erhalte das Abitur-Review",
                subtitle: "Du erhältst ein spannendes Review am Ende deiner Schulzeit",
              ),
              ProductFeature(
                icon: Icons.favorite,
                title: "Unterstütze den Entwickler",
                subtitle: "Hilf dabei, neue Features möglich zu machen",
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ProductActionArea(
        children: [
          ProductButton(
            icon: Icons.shopping_cart,
            loading: purchaseInProgress,
            label: product == null
                ? "Vollversion kaufen"
                : "Vollversion kaufen (${product?.price})",
            onPressed: product == null ? null : _buy,
          ),
        ],
      ),
    );
  }

  void _buy() async {

    if (purchaseInProgress || product == null) return;

    await PurchaseService.buy(product!);

    late final StreamSubscription<PurchaseDetails> sub;
    sub = PurchaseService.purchaseUpdates.listen((purchase) async {
      if (purchase.productID != product!.id) {
        return;
      }
      if (purchase.status == PurchaseStatus.purchased) {
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }

        sub.cancel();

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => widget.nextPage),
          );
        }
      } else if (purchase.status == PurchaseStatus.pending) {
        setState(() {
          purchaseInProgress = true;
        });
      } else if (purchase.status == PurchaseStatus.error) {
        sub.cancel();
        setState(() {
          purchaseInProgress = false;
        });
      }
    });
  }
}
