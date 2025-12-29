/// Streaming search support for real-time result delivery.
library;

import 'dart:async';
import 'search_result.dart';

/// Represents a chunk of search results with metadata.
class SearchResultChunk<T extends SearchResult> {

  const SearchResultChunk({
    required this.results,
    required this.engine,
    this.isFinal = false,
    this.totalResultsSoFar = 0,
    this.fetchDuration = Duration.zero,
  });
  /// The results in this chunk.
  final List<T> results;

  /// The engine that provided these results.
  final String engine;

  /// Whether this is the final chunk.
  final bool isFinal;

  /// Total results found so far.
  final int totalResultsSoFar;

  /// Time taken to fetch this chunk.
  final Duration fetchDuration;

  @override
  String toString() => 'SearchResultChunk(engine: $engine, '
      'results: ${results.length}, isFinal: $isFinal)';
}

/// Progress information for streaming searches.
class SearchProgress {

  const SearchProgress({
    required this.enginesQueried,
    required this.totalEngines,
    required this.resultsFound,
    this.completedEngines = const [],
    this.failedEngines = const [],
    this.status = '',
  });
  /// Number of engines queried so far.
  final int enginesQueried;

  /// Total number of engines to query.
  final int totalEngines;

  /// Number of results found so far.
  final int resultsFound;

  /// List of engines that have completed.
  final List<String> completedEngines;

  /// List of engines that failed.
  final List<String> failedEngines;

  /// Current status message.
  final String status;

  /// Progress percentage (0-100).
  double get progressPercent =>
      totalEngines > 0 ? enginesQueried / totalEngines * 100 : 0;

  /// Check if search is complete.
  bool get isComplete => enginesQueried >= totalEngines;

  @override
  String toString() => 'SearchProgress($enginesQueried/$totalEngines engines, '
      '$resultsFound results)';
}

/// Event types for streaming search.
sealed class SearchEvent<T extends SearchResult> {
  const SearchEvent();
}

/// New results received event.
class ResultsEvent<T extends SearchResult> extends SearchEvent<T> {
  const ResultsEvent(this.chunk);
  final SearchResultChunk<T> chunk;
}

/// Progress update event.
class ProgressEvent<T extends SearchResult> extends SearchEvent<T> {
  const ProgressEvent(this.progress);
  final SearchProgress progress;
}

/// Error event (non-fatal, search continues).
class ErrorEvent<T extends SearchResult> extends SearchEvent<T> {
  const ErrorEvent(this.engine, this.error);
  final String engine;
  final String error;
}

/// Search completed event.
class CompletedEvent<T extends SearchResult> extends SearchEvent<T> {

  const CompletedEvent({
    required this.allResults,
    required this.totalDuration,
    required this.finalProgress,
  });
  final List<T> allResults;
  final Duration totalDuration;
  final SearchProgress finalProgress;
}

/// Streaming search controller for managing async search operations.
class StreamingSearchController<T extends SearchResult> {
  final _controller = StreamController<SearchEvent<T>>.broadcast();
  final List<T> _allResults = [];
  bool _isCancelled = false;
  DateTime? _startTime;

  /// Stream of search events.
  Stream<SearchEvent<T>> get stream => _controller.stream;

  /// All results collected so far.
  List<T> get results => List.unmodifiable(_allResults);

  /// Whether the search has been cancelled.
  bool get isCancelled => _isCancelled;

  /// Start tracking search time.
  void start() {
    _startTime = DateTime.now();
  }

  /// Emit new results.
  void addResults(SearchResultChunk<T> chunk) {
    if (_isCancelled) return;
    _allResults.addAll(chunk.results);
    _controller.add(ResultsEvent(chunk));
  }

  /// Emit progress update.
  void updateProgress(SearchProgress progress) {
    if (_isCancelled) return;
    _controller.add(ProgressEvent(progress));
  }

  /// Emit error (non-fatal).
  void addError(String engine, String error) {
    if (_isCancelled) return;
    _controller.add(ErrorEvent(engine, error));
  }

  /// Complete the search.
  void complete(SearchProgress finalProgress) {
    if (_isCancelled) return;
    _controller.add(CompletedEvent(
      allResults: _allResults,
      totalDuration: _startTime != null
          ? DateTime.now().difference(_startTime!)
          : Duration.zero,
      finalProgress: finalProgress,
    ),);
    _controller.close();
  }

  /// Cancel the search.
  void cancel() {
    _isCancelled = true;
    _controller.close();
  }

  /// Dispose resources.
  Future<void> dispose() async {
    await _controller.close();
  }
}

/// Rate limiter to prevent overwhelming search engines.
class RateLimiter {

  RateLimiter({
    this.maxRequestsPerSecond = 5,
    this.windowDuration = const Duration(seconds: 1),
  });
  final int maxRequestsPerSecond;
  final Duration windowDuration;
  final Map<String, List<DateTime>> _requestTimes = {};

  /// Check if a request can be made to the given engine.
  bool canMakeRequest(String engine) {
    _cleanupOldRequests(engine);
    final times = _requestTimes[engine] ?? [];
    return times.length < maxRequestsPerSecond;
  }

  /// Record a request to the given engine.
  void recordRequest(String engine) {
    _requestTimes.putIfAbsent(engine, () => []);
    _requestTimes[engine]!.add(DateTime.now());
  }

  /// Wait until a request can be made to the given engine.
  Future<void> waitForSlot(String engine) async {
    while (!canMakeRequest(engine)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Get time until next available slot.
  Duration? timeUntilNextSlot(String engine) {
    _cleanupOldRequests(engine);
    final times = _requestTimes[engine] ?? [];
    if (times.length < maxRequestsPerSecond) return Duration.zero;

    final oldestInWindow = times.first;
    final nextAvailable = oldestInWindow.add(windowDuration);
    final waitTime = nextAvailable.difference(DateTime.now());
    return waitTime.isNegative ? Duration.zero : waitTime;
  }

  void _cleanupOldRequests(String engine) {
    final cutoff = DateTime.now().subtract(windowDuration);
    _requestTimes[engine]?.removeWhere((t) => t.isBefore(cutoff));
  }

  /// Reset rate limiting for all engines.
  void reset() => _requestTimes.clear();

  /// Reset rate limiting for a specific engine.
  void resetEngine(String engine) => _requestTimes.remove(engine);
}

/// Retry configuration for failed requests.
class RetryConfig {

  const RetryConfig({
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
    this.exponentialBackoff = true,
    this.retryableStatusCodes = const {408, 429, 500, 502, 503, 504},
  });
  /// Maximum number of retry attempts.
  final int maxRetries;

  /// Base delay between retries (exponential backoff).
  final Duration baseDelay;

  /// Maximum delay between retries.
  final Duration maxDelay;

  /// Whether to use exponential backoff.
  final bool exponentialBackoff;

  /// HTTP status codes that should trigger a retry.
  final Set<int> retryableStatusCodes;

  /// No retries.
  static const none = RetryConfig(maxRetries: 0);

  /// Aggressive retry strategy.
  static const aggressive = RetryConfig(
    maxRetries: 5,
    baseDelay: Duration(milliseconds: 200),
    maxDelay: Duration(seconds: 30),
  );

  /// Calculate delay for a given attempt.
  Duration getDelay(int attempt) {
    if (!exponentialBackoff) return baseDelay;

    final delay = baseDelay * (1 << attempt); // 2^attempt
    return delay > maxDelay ? maxDelay : delay;
  }

  /// Check if a status code should trigger a retry.
  bool shouldRetry(int statusCode) => retryableStatusCodes.contains(statusCode);
}
