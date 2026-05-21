import 'package:flutter/material.dart';

enum ProductButtonType {
  icon,
  tonal,
}

class ProductButton extends StatelessWidget {
  final void Function()? onPressed;
  final IconData icon;
  final bool loading;
  final String label;
  final ProductButtonType type;

  const ProductButton({
    super.key,
    required this.icon,
    this.loading = false,
    required this.label,
    required this.onPressed,
  }) : type = ProductButtonType.icon;

  const ProductButton.tonal({
    super.key,
    required this.icon,
    this.loading = false,
    required this.label,
    required this.onPressed,
  }) : type = ProductButtonType.tonal;

  @override
  Widget build(BuildContext context) {
    if (type == ProductButtonType.icon) {
      return FilledButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading ? CircularProgressIndicator(color: Colors.grey, constraints: BoxConstraints(minHeight: 20, minWidth: 20, maxHeight: 20, maxWidth: 20), strokeWidth: 2,) : Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
      );
    } else {
      return FilledButton.tonalIcon(
        onPressed: loading ? null : onPressed,
        icon: loading ? CircularProgressIndicator(color: Colors.grey, constraints: BoxConstraints(minHeight: 20, minWidth: 20, maxHeight: 20, maxWidth: 20), strokeWidth: 2,) : Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
      );
    }
  }
}
