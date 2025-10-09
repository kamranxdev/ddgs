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
///     final results = await ddgs.text('Dart programming', maxResults: 5);
///     for (final result in results) {
///       print('${result['title']}: ${result['href']}');
///     }
///   } finally {
///     ddgs.close();
///   }
/// }
/// ```
library ddgs;

export 'src/ddgs_base.dart';
export 'src/exceptions.dart';
export 'src/results.dart';
export 'src/base_search_engine.dart';
