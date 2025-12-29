/// DDGS | Dux Distributed Global Search.
///
/// A metasearch library that aggregates results from diverse web search services.
///
/// This is the Dart port of the original Python DDGS library.
///
/// Example usage:
/// ```dart
/// import 'package:ddgs/ddgs.dart';
///
/// void main() async {
///   final ddgs = DDGS();
///
///   try {
///     // Basic text search
///     final results = await ddgs.text('Dart programming', maxResults: 5);
///     for (final result in results) {
///       print('${result['title']}: ${result['href']}');
///     }
///
///     // With typed results
///     final typedResults = await ddgs.textTyped('Flutter', maxResults: 5);
///     for (final result in typedResults) {
///       print('${result.title}: ${result.href}');
///     }
///
///     // Get instant answer
///     final answer = await ddgs.instantAnswer('weather in london');
///     print(answer?.answer);
///   } finally {
///     ddgs.close();
///   }
/// }
/// ```
library ddgs;

// Core exports
export 'src/ddgs_base.dart';
export 'src/exceptions.dart';
export 'src/results.dart';
export 'src/base_search_engine.dart';

// Enhanced API exports
export 'src/search_result.dart';
export 'src/search_options.dart';
export 'src/streaming.dart';
export 'src/instant_answers.dart';
export 'src/parallel_search.dart';

// Engine registry
export 'src/engines/engines.dart' show getAvailableEngines, supportedCategories, isEngineAvailable;

