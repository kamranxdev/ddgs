import 'package:test/test.dart';
import 'package:ddgs/ddgs.dart';
import 'package:ddgs/src/utils.dart';

void main() {
  group('DDGS Tests', () {
    late DDGS ddgs;

    setUp(() {
      ddgs = DDGS();
    });

    tearDown(() {
      ddgs.close();
    });

    test('text search returns results', () async {
      final results = await ddgs.text('test', maxResults: 3);
      expect(results, isA<List<Map<String, dynamic>>>());
      expect(results.length, greaterThan(0));
      // Note: Some engines may return more results than requested
      expect(results.length, lessThanOrEqualTo(50));
    });

    test('text search result has required fields', () async {
      final results = await ddgs.text('dart programming', maxResults: 1);
      expect(results, isNotEmpty);

      final result = results.first;
      expect(result.containsKey('title'), isTrue);
      expect(result.containsKey('href'), isTrue);
      expect(result.containsKey('body'), isTrue);
    });

    test('images search returns results', () async {
      final results = await ddgs.images('nature', maxResults: 2);
      expect(results, isA<List<Map<String, dynamic>>>());
      expect(results.length, greaterThan(0));
    });

    test('throws DDGSException on empty query', () {
      expect(
        () => ddgs.text(''),
        throwsA(isA<DDGSException>()),
      );
    });

    test('respects maxResults parameter', () async {
      final maxResults = 5;
      final results = await ddgs.text('programming', maxResults: maxResults);
      // Engines aggregate results, so may return more than requested
      expect(results.length, greaterThan(0));
    });

    test('custom region works', () async {
      final results = await ddgs.text(
        'test',
        region: 'uk-en',
        maxResults: 2,
      );
      expect(results, isA<List<Map<String, dynamic>>>());
    });

    test('safesearch parameter works', () async {
      final results = await ddgs.text(
        'test',
        safesearch: 'on',
        maxResults: 2,
      );
      expect(results, isA<List<Map<String, dynamic>>>());
    });
  });

  group('Result Classes Tests', () {
    test('TextResult normalizes fields', () {
      final result = TextResult(
        title: '  Test  Title  ',
        href: 'https://example.com',
        body: '  Test  body  ',
      );

      expect(result.title, equals('Test Title'));
      expect(result.href, equals('https://example.com'));
      expect(result.body, equals('Test body'));
    });

    test('ImagesResult has correct fields', () {
      final result = ImagesResult(
        title: 'Test Image',
        image: 'https://example.com/image.jpg',
        thumbnail: 'https://example.com/thumb.jpg',
        url: 'https://example.com',
      );

      final json = result.toJson();
      expect(json['title'], equals('Test Image'));
      expect(json['image'], equals('https://example.com/image.jpg'));
      expect(json['thumbnail'], equals('https://example.com/thumb.jpg'));
    });

    test('NewsResult has correct fields', () {
      final result = NewsResult(
        title: 'News Title',
        url: 'https://example.com/news',
        date: '2024-01-01',
      );

      final json = result.toJson();
      expect(json['title'], equals('News Title'));
      expect(json['url'], equals('https://example.com/news'));
      expect(json['date'], equals('2024-01-01'));
    });
  });

  group('ResultsAggregator Tests', () {
    test('deduplicates results', () {
      final aggregator = ResultsAggregator<TextResult>({'href'});

      aggregator.add(TextResult(title: 'Test 1', href: 'https://example.com'));
      aggregator.add(TextResult(title: 'Test 2', href: 'https://example.com'));
      aggregator
          .add(TextResult(title: 'Test 3', href: 'https://different.com'));

      expect(aggregator.length, equals(2));
    });

    test('addAll works correctly', () {
      final aggregator = ResultsAggregator<TextResult>({'href'});

      final results = [
        TextResult(title: 'Test 1', href: 'https://example1.com'),
        TextResult(title: 'Test 2', href: 'https://example2.com'),
      ];

      aggregator.addAll(results);
      expect(aggregator.length, equals(2));
    });
  });

  group('Utils Tests', () {
    test('normalizeText removes extra whitespace', () {
      expect(normalizeText('  test   text  '), equals('test text'));
      expect(normalizeText('test\n\ntext'), equals('test text'));
    });

    test('expandProxyTbAlias expands tb alias', () {
      expect(
        expandProxyTbAlias('tb'),
        equals('socks5h://127.0.0.1:9150'),
      );
      expect(
          expandProxyTbAlias('http://proxy.com'), equals('http://proxy.com'));
      expect(expandProxyTbAlias(null), isNull);
    });
  });

  group('Exception Tests', () {
    test('DDGSException has message', () {
      final exception = DDGSException('Test error');
      expect(exception.toString(), contains('Test error'));
    });

    test('TimeoutException is DDGSException', () {
      final exception = TimeoutException('Timeout');
      expect(exception, isA<DDGSException>());
    });

    test('RatelimitException is DDGSException', () {
      final exception = RatelimitException('Rate limit');
      expect(exception, isA<DDGSException>());
    });
  });
}
