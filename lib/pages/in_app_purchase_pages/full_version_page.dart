import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../in_app_purchases/purchase_service.dart';

class FullVersionPage extends StatelessWidget {

  final Widget nextPage;

  const FullVersionPage({super.key, required this.nextPage});

  @override
  Widget build(BuildContext context) {

    final ProductDetails? product = PurchaseService.products
        .where((p) => p.id == PurchaseService.fullVersionProductId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Schalte mehr Features frei.",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ListTile(
              leading: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary, size: 32),
              title: Text(
                "Kalendersynchronisierung",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Synchronisiere Prüfungen bestimmter Typen und Events mit deinem Geräte-Kalender"),
            ),
            ListTile(
              leading: Icon(Icons.widgets, color: Theme.of(context).colorScheme.primary, size: 32),
              title: Row(
                children: [
                  Text(
                    "Widgets",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10,),
                  Badge(
                    label: Text("Demnächst"),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              subtitle: Text("Platziere Widgets auf deinem Homescreen"),
            ),
            ListTile(
              leading: Icon(Icons.query_stats, color: Theme.of(context).colorScheme.primary, size: 32),
              title: Row(
                children: [
                  Text(
                    "Analysen",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10,),
                  Badge(
                    label: Text("Demnächst"),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              subtitle: Text("Profitiere von zusätzlichen Statistiken"),
            ),
            ListTile(
              leading: Icon(Icons.star, color: Theme.of(context).colorScheme.primary, size: 32),
              title: Text(
                "Erhalte das Abitur-Review",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Du erhältst ein spannendes Review am Ende deiner Schulzeit"),
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


              Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) {
                      return nextPage;
                    },
                  ));

            },
            icon: Icon(Icons.shopping_cart),
            label: Text(
              product == null
                  ? "Vollversion kaufen"
                  : "Vollversion kaufen (${product.price})",
            ),
            style: FilledButton.styleFrom(minimumSize: Size(double.infinity, 56)),
          ),
        ),
      ),
    );
  }
}
