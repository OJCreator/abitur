import 'package:abitur/widgets/product_features/product_feature_badge.dart';
import 'package:flutter/material.dart';

class ProductFeature extends StatelessWidget {

  final IconData icon;
  final String title, subtitle;
  final ProductFeatureBadge badge;

  const ProductFeature({super.key, required this.icon, required this.title, this.badge = ProductFeatureBadge.none, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
      title: Row(
        spacing: 10,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (badge != ProductFeatureBadge.none)
            Badge(
              label: Text(badge.title),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
      subtitle: Text(subtitle),
    );
  }
}
