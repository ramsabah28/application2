class CartItemDeletionException implements Exception {
  final String message;
  CartItemDeletionException([this.message = "Cart have no item's!"]);

  @override
  String toString() => 'CartDeletionException: $message';
}
