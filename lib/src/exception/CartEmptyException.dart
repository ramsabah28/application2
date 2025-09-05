class CartParseException implements Exception {
	final String message;
	CartParseException([this.message = 'Cart is empty or data is corrupted.']);

	@override
	String toString() => 'CartParseException: $message';
}
