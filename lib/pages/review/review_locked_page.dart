import 'package:abitur/pages/review/review_page.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../in_app_purchases/purchase_service.dart';

class ReviewLockedPage extends StatelessWidget {

  const ReviewLockedPage({super.key});

  @override
  Widget build(BuildContext context) {

    final ProductDetails? product = PurchaseService.products
        .where((p) => p.id == PurchaseService.abiturReviewProductId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Willkommen zu deinem Abitur-Review.",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ListTile(
              leading: Icon(Icons.star, color: Theme.of(context).colorScheme.primary, size: 32),
              title: Text(
                "Deine Highligts",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Sieh deine persönliche Geschichte der letzten beiden Jahre an"),
            ),
            ListTile(
              leading: Icon(Icons.query_stats, color: Theme.of(context).colorScheme.primary, size: 32),
              title: Text(
                "Erkunde interessante Statistiken",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Darunter der beste Wochentag oder Analysen der Prüfungen"),
            ),
            ListTile(
              leading: Icon(Icons.send, color: Theme.of(context).colorScheme.primary, size: 32),
              title: Text(
                "Teile deine Highlights",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Zeig Freunden deine spannendsten Ergebnisse"),
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary, size: 32),
              title: Text(
                "Unterstütze den Entwickler",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Hilf dabei, neue Features möglich zu machen"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: product == null
                ? null
                : () async {
              await PurchaseService.buy(product);

              Navigator.pushReplacement(context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ReviewPage();
                    },
                  ));

            },
            icon: Icon(Icons.shopping_cart),
            label: Text(
              product == null
                  ? "Review freischalten"
                  : "Review freischalten (${product.price})",
            ),
            style: FilledButton.styleFrom(minimumSize: Size(double.infinity, 56)),
          ),
        ),
      ),
    );
  }
}
