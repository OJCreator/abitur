import 'dart:async';

import 'package:abitur/pages/review/review_page.dart';
import 'package:abitur/widgets/product_features/product_action_area.dart';
import 'package:abitur/widgets/product_features/product_button.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../in_app_purchases/purchase_service.dart';
import '../../widgets/product_features/product_feature.dart';
import '../../widgets/product_features/product_title.dart';

class ReviewLockedPage extends StatefulWidget {

  const ReviewLockedPage({super.key});

  @override
  State<ReviewLockedPage> createState() => _ReviewLockedPageState();
}

class _ReviewLockedPageState extends State<ReviewLockedPage> {

  late final ProductDetails? product;

  bool purchaseInProgress = false;

  @override
  void initState() {

    product = PurchaseService.products
        .where((p) => p.id == PurchaseService.abiturReviewProductId)
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
                "Willkommen zu deinem Abitur-Review.",
              ),

              ProductFeature(
                icon: Icons.star,
                title: "Deine Highligts",
                subtitle: "Sieh deine persönliche Geschichte der letzten beiden Jahre an",
              ),
              ProductFeature(
                icon: Icons.query_stats,
                title: "Erkunde interessante Statistiken",
                subtitle: "Darunter der beste Wochentag oder Analysen der Prüfungen",
              ),
              ProductFeature(
                icon: Icons.send,
                title: "Teile deine Highlights",
                subtitle: "Zeig Freunden deine spannendsten Ergebnisse",
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
                ? "Review freischalten"
                : "Review freischalten (${product?.price})",
            onPressed: product == null
                ? null
                : _buy,
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
            MaterialPageRoute(builder: (_) => ReviewPage()),
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
