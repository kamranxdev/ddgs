/// DDGS exceptions.
library;

/// Base exception class for ddgs.
class DDGSException implements Exception {

  DDGSException(this.message);
  final String message;

  @override
  String toString() => 'DDGSException: $message';
}

/// Raised for rate limit exceeded errors during API requests.
class RatelimitException extends DDGSException {
  RatelimitException(super.message);

  @override
  String toString() => 'RatelimitException: $message';
}

/// Raised for timeout errors during API requests.
class TimeoutException extends DDGSException {
  TimeoutException(super.message);

  @override
  String toString() => 'TimeoutException: $message';
}
