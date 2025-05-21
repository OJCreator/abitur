class InvalidFormException implements Exception {
  final String message;

  InvalidFormException(this.message);

  @override
  String toString() => 'InvalidFormException: $message';
}