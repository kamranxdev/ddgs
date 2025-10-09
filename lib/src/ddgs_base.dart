/// DDGS class implementation.

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'base_search_engine.dart';
import 'engines/engines.dart';
import 'exceptions.dart';
import 'results.dart';
import 'utils.dart';

/// DDGS | Dux Distributed Global Search.
///
/// A metasearch library that aggregates results from diverse web search services.
///
/// Example:
/// ```dart
/// final ddgs = DDGS();
/// final results = await ddgs.text('python programming');
/// ddgs.close();
/// ```
class DDGS {
  final String? _proxy;
  final Duration _timeout;
  final bool _verify;
  final Map<Type, BaseSearchEngine> _enginesCache = {};

  /// Number of threads/isolates to use for search.
  int? threads;

  DDGS({
    String? proxy,
    Duration? timeout,
    bool verify = true,
  })  : _proxy =
            expandProxyTbAlias(proxy) ?? Platform.environment['DDGS_PROXY'],
        _timeout = timeout ?? const Duration(seconds: 5),
        _verify = verify;

  /// Get search engine instances for a category and backend.
  List<BaseSearchEngine> _getEngines(String category, String backend) {
    final backendList = backend.split(',').map((e) => e.trim()).toList();
    var engineKeys = engines[category]?.keys.toList() ?? [];
    engineKeys.shuffle();

    List<String> keys;
    if (backendList.contains('auto') || backendList.contains('all')) {
      keys = engineKeys;
      if (category == 'text') {
        // Ensure Wikipedia is always included and in first position
        keys = ['wikipedia', ...keys.where((k) => k != 'wikipedia')];
      }
    } else {
      keys = backendList;
    }

    try {
      final instances = <BaseSearchEngine>[];
      for (final key in keys) {
        final engineClass = engines[category]?[key];
        if (engineClass == null) continue;

        // Use cached instance if available
        if (_enginesCache.containsKey(engineClass.runtimeType)) {
          instances.add(_enginesCache[engineClass.runtimeType]!);
        } else {
          final instance = engineClass(
            proxy: _proxy,
            timeout: _timeout,
            verify: _verify,
          );
          _enginesCache[engineClass.runtimeType] = instance;
          instances.add(instance);
        }
      }

      // Sort by priority
      instances.sort((a, b) {
        final priorityCompare = b.priority.compareTo(a.priority);
        if (priorityCompare != 0) return priorityCompare;
        return Random().nextBool() ? 1 : -1;
      });

      return instances;
    } catch (e) {
      // If backend doesn't exist, fall back to auto
      return _getEngines(category, 'auto');
    }
  }

  /// Perform a search across engines in the given category.
  Future<List<Map<String, dynamic>>> _search({
    required String category,
    required String query,
    String region = 'us-en',
    String safesearch = 'moderate',
    String? timelimit,
    int? maxResults = 10,
    int page = 1,
    String backend = 'auto',
    Map<String, dynamic>? extra,
  }) async {
    if (query.isEmpty) {
      throw DDGSException('query is mandatory.');
    }

    final enginesList = _getEngines(category, backend);
    final uniqueProviders = enginesList.map((e) => e.provider).toSet();
    final seenProviders = <String>{};

    // Create results aggregator based on category
    final Set<String> uniqueFields;
    switch (category) {
      case 'images':
        uniqueFields = {'image', 'url'};
        break;
      case 'videos':
        uniqueFields = {'embed_url'};
        break;
      default:
        uniqueFields = {'href', 'url'};
    }

    final resultsAggregator = ResultsAggregator<BaseResult>(uniqueFields);
    final maxWorkers = maxResults != null
        ? min(uniqueProviders.length, (maxResults / 10).ceil() + 1)
        : uniqueProviders.length;

    final futures = <Future<void>>[];
    var workersStarted = 0;

    for (final engine in enginesList) {
      if (seenProviders.contains(engine.provider)) {
        continue;
      }

      final future = _executeEngineSearch(
        engine,
        query,
        region,
        safesearch,
        timelimit,
        page,
        maxResults,
        extra,
        resultsAggregator,
        seenProviders,
      );
      futures.add(future);
      workersStarted++;

      if (workersStarted >= maxWorkers) {
        await Future.wait(futures, eagerError: false);
        futures.clear();
      }
    }

    // Wait for remaining futures
    if (futures.isNotEmpty) {
      await Future.wait(futures, eagerError: false);
    }

    // Convert results to JSON
    return resultsAggregator.results.map((r) => r.toJson()).toList();
  }

  Future<void> _executeEngineSearch(
    BaseSearchEngine engine,
    String query,
    String region,
    String safesearch,
    String? timelimit,
    int page,
    int? maxResults,
    Map<String, dynamic>? extra,
    ResultsAggregator resultsAggregator,
    Set<String> seenProviders,
  ) async {
    try {
      final results = await engine
          .search(
            query: query,
            region: region,
            safesearch: safesearch,
            timelimit: timelimit,
            page: page,
            extra: extra,
          )
          .timeout(_timeout);

      if (results != null && results.isNotEmpty) {
        resultsAggregator.addAll(results);
        seenProviders.add(engine.provider);
      }
    } catch (e) {
      // Log error but continue with other engines
      print('Error in engine ${engine.name}: $e');
    }
  }

  /// Text search.
  ///
  /// Args:
  ///   query: Search query.
  ///   region: Region code (e.g., 'us-en', 'uk-en').
  ///   safesearch: Safe search setting ('on', 'moderate', 'off').
  ///   timelimit: Time limit ('d', 'w', 'm', 'y').
  ///   maxResults: Maximum number of results to return.
  ///   page: Page number.
  ///   backend: Backend(s) to use (comma-separated or 'auto').
  ///
  /// Returns:
  ///   List of text search results.
  Future<List<Map<String, dynamic>>> text(
    String query, {
    String region = 'us-en',
    String safesearch = 'moderate',
    String? timelimit,
    int? maxResults = 10,
    int page = 1,
    String backend = 'auto',
  }) {
    return _search(
      category: 'text',
      query: query,
      region: region,
      safesearch: safesearch,
      timelimit: timelimit,
      maxResults: maxResults,
      page: page,
      backend: backend,
    );
  }

  /// Image search.
  Future<List<Map<String, dynamic>>> images(
    String query, {
    String region = 'us-en',
    String safesearch = 'moderate',
    String? timelimit,
    int? maxResults = 10,
    int page = 1,
    String backend = 'auto',
  }) {
    return _search(
      category: 'images',
      query: query,
      region: region,
      safesearch: safesearch,
      timelimit: timelimit,
      maxResults: maxResults,
      page: page,
      backend: backend,
    );
  }

  /// Video search.
  Future<List<Map<String, dynamic>>> videos(
    String query, {
    String region = 'us-en',
    String safesearch = 'moderate',
    String? timelimit,
    int? maxResults = 10,
    int page = 1,
    String backend = 'auto',
  }) {
    return _search(
      category: 'videos',
      query: query,
      region: region,
      safesearch: safesearch,
      timelimit: timelimit,
      maxResults: maxResults,
      page: page,
      backend: backend,
    );
  }

  /// News search.
  Future<List<Map<String, dynamic>>> news(
    String query, {
    String region = 'us-en',
    String safesearch = 'moderate',
    String? timelimit,
    int? maxResults = 10,
    int page = 1,
    String backend = 'auto',
  }) {
    return _search(
      category: 'news',
      query: query,
      region: region,
      safesearch: safesearch,
      timelimit: timelimit,
      maxResults: maxResults,
      page: page,
      backend: backend,
    );
  }

  /// Books search.
  Future<List<Map<String, dynamic>>> books(
    String query, {
    String region = 'us-en',
    String safesearch = 'moderate',
    int? maxResults = 10,
    int page = 1,
    String backend = 'auto',
  }) {
    return _search(
      category: 'books',
      query: query,
      region: region,
      safesearch: safesearch,
      maxResults: maxResults,
      page: page,
      backend: backend,
    );
  }

  /// Close all HTTP clients.
  void close() {
    for (final engine in _enginesCache.values) {
      engine.close();
    }
    _enginesCache.clear();
  }
}
