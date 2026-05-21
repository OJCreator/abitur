enum ProductFeatureBadge {
  none,
  comingSoon,
  beta;

  String get title {
    switch (this) {
      case none: return "None";
      case comingSoon: return "Demnächst";
      case beta: return "Beta";
    }
  }
}
