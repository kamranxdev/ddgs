/// Bing search engine implementation.

import 'dart:convert';
import '../base_search_engine.dart';
import '../results.dart';

/// Unwrap Bing-wrapped URL to extract original URL.
String? unwrapBingUrl(String rawUrl) {
  try {
    final uri = Uri.parse(rawUrl);
    final uVals = uri.queryParameters['u'];
    if (uVals == null || uVals.length <= 2) return null;

    // Drop first two characters, pad to multiple of 4, then decode
    final b64Part = uVals.substring(2);
    final padding = '=' * (4 - b64Part.length % 4);
    final decoded =
        base64Url.decode(b64Part + (padding == '====' ? '' : padding));
    return utf8.decode(decoded);
  } catch (e) {
    return null;
  }
}

/// Bing search engine.
class BingEngine extends BaseSearchEngine<TextResult> {
  BingEngine({super.proxy, super.timeout, super.verify});

  @override
  String get name => 'bing';

  @override
  String get category => 'text';

  @override
  String get provider => 'bing';

  @override
  String get searchUrl => 'https://www.bing.com/search';

  @override
  String get searchMethod => 'GET';

  @override
  String get itemsSelector => 'li.b_algo';

  @override
  Map<String, String> get elementsSelector => {
        'title': 'h2 a',
        'href': 'h2 a',
        'body': 'p',
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
    final parts = region.toLowerCase().split('-');
    // Note: Bing uses lang code, country code not needed for query
    final lang = parts.length > 1 ? parts[1] : parts[0];

    final payload = {
      'q': query,
      'pq': query,
      'cc': lang,
    };

    if (timelimit != null) {
      final d = (DateTime.now().millisecondsSinceEpoch / 86400000).floor();
      final code = timelimit == 'y'
          ? 'ez5_${d - 365}_$d'
          : 'ez${{'d': '1', 'w': '2', 'm': '3'}[timelimit]}';
      payload['filters'] = 'ex1:"$code"';
    }

    if (page > 1) {
      payload['first'] = '${(page - 1) * 10}';
      payload['FORM'] = 'PERE${page > 2 ? page - 2 : ''}';
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
      var href = hrefElement?.attributes['href'] ?? '';
      final body = bodyElement?.text ?? '';

      // Unwrap Bing URLs
      if (href.startsWith('https://www.bing.com/ck/a?')) {
        href = unwrapBingUrl(href) ?? href;
      }

      if ((title.isNotEmpty || href.isNotEmpty) &&
          !href.startsWith('https://www.bing.com/aclick?')) {
        results.add(TextResult(title: title, href: href, body: body));
      }
    }

    return results;
  }
}
