/// DuckDuckGo search engine implementation.
library;

import '../base_search_engine.dart';
import '../results.dart';

/// DuckDuckGo search engine (stub implementation).
class DuckDuckGoEngine extends BaseSearchEngine<TextResult> {
  DuckDuckGoEngine({super.proxy, super.timeout, super.verify});

  @override
  String get name => 'duckduckgo';

  @override
  String get category => 'text';

  @override
  String get provider => 'duckduckgo';

  @override
  String get searchUrl => 'https://duckduckgo.com/html/';

  @override
  String get searchMethod => 'GET';

  @override
  String get itemsSelector => '.result';

  @override
  Map<String, String> get elementsSelector => {
        'title': '.result__title',
        'href': '.result__url',
        'body': '.result__snippet',
      };

  @override
  Map<String, String> buildPayload({
    required String query,
    required String region,
    required String safesearch,
    String? timelimit,
    int page = 1,
    Map<String, dynamic>? extra,
  }) {
    final safesearchMap = {'on': '1', 'moderate': '0', 'off': '-1'};

    final payload = {
      'q': query,
      'kl': region,
      'p': safesearchMap[safesearch.toLowerCase()] ?? '0',
    };

    if (timelimit != null) {
      payload['df'] = timelimit;
    }

    return payload;
  }

  @override
  List<TextResult> extractResults(String htmlText) {
    final results = <TextResult>[];
    final document = extractTree(htmlText);
    final items = document.querySelectorAll(itemsSelector);

    for (final item in items) {
      final titleElement = item.querySelector(elementsSelector['title']!);
      final hrefElement = item.querySelector(elementsSelector['href']!);
      final bodyElement = item.querySelector(elementsSelector['body']!);

      final title = titleElement?.text ?? '';
      final href = hrefElement?.text ?? '';
      final body = bodyElement?.text ?? '';

      if (title.isNotEmpty || href.isNotEmpty) {
        results.add(TextResult(title: title, href: href, body: body));
      }
    }

    return results;
  }
}
