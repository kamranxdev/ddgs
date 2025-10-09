/// Base class for search engines.

import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'http_client.dart';
import 'results.dart';

/// Abstract base class for all search-engine backends.
abstract class BaseSearchEngine<T extends BaseResult> {
  /// Unique key, e.g. "google"
  String get name;

  /// Category of search: text, images, videos, news, books
  String get category;

  /// Source of the search results (e.g. "google" for MullVadLetaGoogle)
  String get provider;

  /// If true, the engine is disabled
  bool get disabled => false;

  /// Engine priority
  double get priority => 1.0;

  /// Search URL
  String get searchUrl;

  /// Search method: GET or POST
  String get searchMethod;

  /// Search headers
  Map<String, String> get searchHeaders => {};

  /// XPath for items
  String get itemsSelector;

  /// CSS selectors for elements
  Map<String, String> get elementsSelector;

  final HttpClient httpClient;
  final List<T> results = [];

  BaseSearchEngine({
    String? proxy,
    Duration? timeout,
    bool verify = true,
  }) : httpClient = HttpClient(
          proxy: proxy,
          timeout: timeout,
          verify: verify,
        );

  /// Build a payload for the search request.
  Map<String, String> buildPayload({
    required String query,
    required String region,
    required String safesearch,
    String? timelimit,
    int page = 1,
    Map<String, dynamic>? extra,
  });

  /// Make a request to the search engine.
  Future<String?> request(
    String method,
    String url, {
    Map<String, String>? params,
    Map<String, String>? headers,
    dynamic data,
  }) async {
    try {
      final uri = Uri.parse(url);
      final response = await httpClient.request(
        method,
        uri,
        params: params,
        headers: headers,
        body: data,
      );
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// Extract HTML document from text.
  Document extractTree(String htmlText) {
    return html_parser.parse(htmlText);
  }

  /// Pre-process HTML text before extracting results.
  String preProcessHtml(String htmlText) {
    return htmlText;
  }

  /// Extract search results from HTML text.
  List<T> extractResults(String htmlText);

  /// Post-process search results.
  List<T> postExtractResults(List<T> results) {
    return results;
  }

  /// Search the engine.
  Future<List<T>?> search({
    required String query,
    String region = 'us-en',
    String safesearch = 'moderate',
    String? timelimit,
    int page = 1,
    Map<String, dynamic>? extra,
  }) async {
    final payload = buildPayload(
      query: query,
      region: region,
      safesearch: safesearch,
      timelimit: timelimit,
      page: page,
      extra: extra,
    );

    String? htmlText;
    if (searchMethod.toUpperCase() == 'GET') {
      htmlText = await request(
        searchMethod,
        searchUrl,
        params: payload,
        headers: searchHeaders,
      );
    } else {
      htmlText = await request(
        searchMethod,
        searchUrl,
        data: payload,
        headers: searchHeaders,
      );
    }

    if (htmlText == null) {
      return null;
    }

    final results = extractResults(htmlText);
    return postExtractResults(results);
  }

  void close() {
    httpClient.close();
  }
}
