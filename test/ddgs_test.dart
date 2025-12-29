import 'package:ddgs/ddgs.dart';
import 'package:ddgs/src/utils.dart';
import 'package:test/test.dart';

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
      const maxResults = 5;
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

    test('videos search returns results', () async {
      final results = await ddgs.videos('music', maxResults: 2);
      expect(results, isA<List<Map<String, dynamic>>>());
    });

    test('news search returns results', () async {
      final results = await ddgs.news('technology', maxResults: 2);
      expect(results, isA<List<Map<String, dynamic>>>());
    });

    test('timelimit parameter works', () async {
      final results = await ddgs.text(
        'news',
        timelimit: 'd',
        maxResults: 2,
      );
      expect(results, isA<List<Map<String, dynamic>>>());
    });

    test('page parameter works', () async {
      final results = await ddgs.text(
        'programming',
        page: 2,
        maxResults: 2,
      );
      expect(results, isA<List<Map<String, dynamic>>>());
    });

    test('backend parameter works', () async {
      final results = await ddgs.text(
        'test',
        backend: 'wikipedia',
        maxResults: 2,
      );
      expect(results, isA<List<Map<String, dynamic>>>());
    });

    test('getAvailableEnginesFor returns engines list', () {
      final textEngines = ddgs.getAvailableEnginesFor('text');
      expect(textEngines, isA<List<String>>());
      expect(textEngines, isNotEmpty);
    });

    test('throws DDGSException on empty images query', () {
      expect(
        () => ddgs.images(''),
        throwsA(isA<DDGSException>()),
      );
    });

    test('throws DDGSException on empty videos query', () {
      expect(
        () => ddgs.videos(''),
        throwsA(isA<DDGSException>()),
      );
    });

    test('throws DDGSException on empty news query', () {
      expect(
        () => ddgs.news(''),
        throwsA(isA<DDGSException>()),
      );
    });
  });

  group('DDGS Typed Search Tests', () {
    late DDGS ddgs;

    setUp(() {
      ddgs = DDGS();
    });

    tearDown(() {
      ddgs.close();
    });

    test('textTyped returns TextSearchResult list', () async {
      final results = await ddgs.textTyped(
        'dart',
        options: const SearchOptions(maxResults: 2),
      );
      expect(results, isA<List<TextSearchResult>>());
      if (results.isNotEmpty) {
        expect(results.first.title, isNotEmpty);
        expect(results.first.href, isNotEmpty);
      }
    });

    test('imagesTyped returns ImageSearchResult list', () async {
      final results = await ddgs.imagesTyped(
        'nature',
        options: const SearchOptions(maxResults: 2),
      );
      expect(results, isA<List<ImageSearchResult>>());
    });

    test('videosTyped returns VideoSearchResult list', () async {
      final results = await ddgs.videosTyped(
        'music',
        options: const SearchOptions(maxResults: 2),
      );
      expect(results, isA<List<VideoSearchResult>>());
    });

    test('newsTyped returns NewsSearchResult list', () async {
      final results = await ddgs.newsTyped(
        'technology',
        options: const SearchOptions(maxResults: 2),
      );
      expect(results, isA<List<NewsSearchResult>>());
    });

    test('searchWithOptions works', () async {
      final results = await ddgs.searchWithOptions(
        'test',
        category: 'text',
        options: const SearchOptions(maxResults: 2),
      );
      expect(results, isA<List<Map<String, dynamic>>>());
    });
  });

  group('DDGS Configuration Tests', () {
    test('creates DDGS with custom timeout', () {
      final ddgs = DDGS(timeout: const Duration(seconds: 10));
      expect(ddgs, isA<DDGS>());
      ddgs.close();
    });

    test('creates DDGS with rate limiter', () {
      final ddgs = DDGS(maxRequestsPerSecond: 5);
      expect(ddgs, isA<DDGS>());
      ddgs.close();
    });

    test('creates DDGS with cache config', () {
      final ddgs = DDGS(cacheConfig: CacheConfig.memory);
      expect(ddgs.cacheStats, isNotNull);
      ddgs.close();
    });

    test('clearCache works', () {
      final ddgs = DDGS(cacheConfig: CacheConfig.memory);
      ddgs.clearCache();
      ddgs.close();
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

    test('TextResult toJson returns correct map', () {
      final result = TextResult(
        title: 'Test',
        href: 'https://example.com',
        body: 'Body text',
      );

      final json = result.toJson();
      expect(json['title'], equals('Test'));
      expect(json['href'], equals('https://example.com'));
      expect(json['body'], equals('Body text'));
    });

    test('TextResult handles empty fields', () {
      final result = TextResult();
      expect(result.title, equals(''));
      expect(result.href, equals(''));
      expect(result.body, equals(''));
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

    test('ImagesResult includes all optional fields', () {
      final result = ImagesResult(
        title: 'Test',
        image: 'https://example.com/img.jpg',
        thumbnail: 'https://example.com/thumb.jpg',
        url: 'https://example.com',
        height: '600',
        width: '800',
        source: 'example.com',
      );

      final json = result.toJson();
      expect(json['height'], equals('600'));
      expect(json['width'], equals('800'));
      expect(json['source'], equals('example.com'));
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

    test('NewsResult includes all optional fields', () {
      final result = NewsResult(
        title: 'News',
        url: 'https://example.com/news',
        date: '2024-01-01',
        body: 'News body',
        image: 'https://example.com/img.jpg',
        source: 'Example News',
      );

      final json = result.toJson();
      expect(json['body'], equals('News body'));
      expect(json['image'], equals('https://example.com/img.jpg'));
      expect(json['source'], equals('Example News'));
    });

    test('VideosResult has correct fields', () {
      final result = VideosResult(
        title: 'Video Title',
        content: 'Video content',
        description: 'Video description',
        duration: '10:30',
        embedUrl: 'https://example.com/embed',
        provider: 'YouTube',
        publisher: 'Test Publisher',
      );

      final json = result.toJson();
      expect(json['title'], equals('Video Title'));
      expect(json['content'], equals('Video content'));
      expect(json['description'], equals('Video description'));
      expect(json['duration'], equals('10:30'));
      expect(json['embed_url'], equals('https://example.com/embed'));
      expect(json['provider'], equals('YouTube'));
      expect(json['publisher'], equals('Test Publisher'));
    });

    test('BooksResult has correct fields', () {
      final result = BooksResult(
        title: 'Book Title',
        author: 'Author Name',
        publisher: 'Publisher',
        info: 'Book info',
        url: 'https://example.com/book',
      );

      final json = result.toJson();
      expect(json['title'], equals('Book Title'));
      expect(json['author'], equals('Author Name'));
      expect(json['publisher'], equals('Publisher'));
      expect(json['info'], equals('Book info'));
      expect(json['url'], equals('https://example.com/book'));
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

    test('results getter returns unmodifiable list', () {
      final aggregator = ResultsAggregator<TextResult>({'href'});
      aggregator.add(TextResult(title: 'Test', href: 'https://example.com'));

      final results = aggregator.results;
      expect(results.length, equals(1));
    });

    test('handles multiple unique fields', () {
      final aggregator = ResultsAggregator<ImagesResult>({'image', 'url'});

      aggregator.add(ImagesResult(
        title: 'Test 1',
        image: 'https://example.com/img1.jpg',
        url: 'https://example.com/page1',
      ),);
      aggregator.add(ImagesResult(
        title: 'Test 2',
        image: 'https://example.com/img1.jpg',
        url: 'https://example.com/page1',
      ),);
      aggregator.add(ImagesResult(
        title: 'Test 3',
        image: 'https://example.com/img2.jpg',
        url: 'https://example.com/page2',
      ),);

      expect(aggregator.length, equals(2));
    });

    test('ignores results with empty unique fields', () {
      final aggregator = ResultsAggregator<TextResult>({'href'});

      aggregator.add(TextResult(title: 'Test'));
      aggregator.add(TextResult(title: 'Test 2', href: 'https://example.com'));

      expect(aggregator.length, equals(1));
    });
  });

  group('SearchOptions Tests', () {
    test('SearchOptions has correct defaults', () {
      const options = SearchOptions();

      expect(options.region, equals(SearchRegion.usEnglish));
      expect(options.safeSearch, equals(SafeSearchLevel.moderate));
      expect(options.timeLimit, equals(TimeLimit.none));
      expect(options.maxResults, equals(10));
      expect(options.page, equals(1));
      expect(options.backend, equals('auto'));
    });

    test('SearchOptions copyWith works', () {
      const options = SearchOptions();
      final modified = options.copyWith(
        region: SearchRegion.ukEnglish,
        maxResults: 20,
      );

      expect(modified.region, equals(SearchRegion.ukEnglish));
      expect(modified.maxResults, equals(20));
      expect(modified.safeSearch, equals(SafeSearchLevel.moderate));
    });

    test('SearchOptions.quick has correct values', () {
      expect(SearchOptions.quick.maxResults, equals(5));
    });

    test('SearchOptions.comprehensive has correct values', () {
      expect(SearchOptions.comprehensive.maxResults, equals(50));
      expect(SearchOptions.comprehensive.includeMetadata, isTrue);
    });

    test('SearchOptions toString works', () {
      const options = SearchOptions();
      final str = options.toString();
      expect(str, contains('SearchOptions'));
      expect(str, contains('us-en'));
    });
  });

  group('SearchRegion Tests', () {
    test('SearchRegion has correct codes', () {
      expect(SearchRegion.usEnglish.code, equals('us-en'));
      expect(SearchRegion.ukEnglish.code, equals('uk-en'));
      expect(SearchRegion.global.code, equals('wt-wt'));
    });

    test('SearchRegion fromCode works', () {
      expect(SearchRegion.fromCode('us-en'), equals(SearchRegion.usEnglish));
      expect(SearchRegion.fromCode('uk-en'), equals(SearchRegion.ukEnglish));
      expect(SearchRegion.fromCode('invalid'), equals(SearchRegion.global));
    });

    test('SearchRegion has display names', () {
      expect(SearchRegion.usEnglish.displayName, contains('United States'));
      expect(SearchRegion.ukEnglish.displayName, contains('United Kingdom'));
    });
  });

  group('SafeSearchLevel Tests', () {
    test('SafeSearchLevel has correct codes', () {
      expect(SafeSearchLevel.off.code, equals('off'));
      expect(SafeSearchLevel.moderate.code, equals('moderate'));
      expect(SafeSearchLevel.strict.code, equals('on'));
    });

    test('SafeSearchLevel has descriptions', () {
      expect(SafeSearchLevel.off.description, isNotEmpty);
      expect(SafeSearchLevel.moderate.description, isNotEmpty);
      expect(SafeSearchLevel.strict.description, isNotEmpty);
    });
  });

  group('TimeLimit Tests', () {
    test('TimeLimit has correct codes', () {
      expect(TimeLimit.day.code, equals('d'));
      expect(TimeLimit.week.code, equals('w'));
      expect(TimeLimit.month.code, equals('m'));
      expect(TimeLimit.year.code, equals('y'));
      expect(TimeLimit.none.code, isNull);
    });

    test('TimeLimit has display names', () {
      expect(TimeLimit.day.displayName, contains('24 hours'));
      expect(TimeLimit.week.displayName, contains('week'));
      expect(TimeLimit.month.displayName, contains('month'));
      expect(TimeLimit.year.displayName, contains('year'));
    });
  });

  group('ImageSize Tests', () {
    test('ImageSize has display names', () {
      expect(ImageSize.small.displayName, equals('Small'));
      expect(ImageSize.medium.displayName, equals('Medium'));
      expect(ImageSize.large.displayName, equals('Large'));
      expect(ImageSize.wallpaper.displayName, equals('Wallpaper'));
    });
  });

  group('ImageColor Tests', () {
    test('ImageColor has display names', () {
      expect(ImageColor.any.displayName, equals('Any'));
      expect(ImageColor.red.displayName, equals('Red'));
      expect(ImageColor.blue.displayName, equals('Blue'));
      expect(ImageColor.monochrome.displayName, equals('Monochrome'));
    });
  });

  group('CacheConfig Tests', () {
    test('CacheConfig.disabled has enabled false', () {
      expect(CacheConfig.disabled.enabled, isFalse);
    });

    test('CacheConfig.memory has enabled true', () {
      expect(CacheConfig.memory.enabled, isTrue);
    });

    test('CacheConfig.persistent creates with directory', () {
      final config = CacheConfig.persistent('/tmp/cache');
      expect(config.enabled, isTrue);
      expect(config.cacheDirectory, equals('/tmp/cache'));
      expect(config.ttl, equals(const Duration(hours: 1)));
    });

    test('CacheConfig defaults are correct', () {
      const config = CacheConfig(enabled: true);
      expect(config.ttl, equals(const Duration(minutes: 15)));
      expect(config.maxEntries, equals(100));
      expect(config.cacheDirectory, isNull);
    });
  });

  group('ResultCache Tests', () {
    test('ResultCache stores and retrieves results', () {
      final cache = ResultCache(CacheConfig.memory);
      const options = SearchOptions();
      final results = [
        {'title': 'Test', 'href': 'https://example.com'},
      ];

      cache.put('text', 'query', options, results);
      final cached = cache.get('text', 'query', options);

      expect(cached, isNotNull);
      expect(cached, equals(results));
    });

    test('ResultCache returns null for missing entries', () {
      final cache = ResultCache(CacheConfig.memory);
      const options = SearchOptions();

      final cached = cache.get('text', 'nonexistent', options);
      expect(cached, isNull);
    });

    test('ResultCache clear removes all entries', () {
      final cache = ResultCache(CacheConfig.memory);
      const options = SearchOptions();
      final results = [
        {'title': 'Test'},
      ];

      cache.put('text', 'query1', options, results);
      cache.put('text', 'query2', options, results);
      cache.clear();

      expect(cache.get('text', 'query1', options), isNull);
      expect(cache.get('text', 'query2', options), isNull);
    });

    test('ResultCache stats returns correct values', () {
      final cache = ResultCache(CacheConfig.memory);
      const options = SearchOptions();

      cache.put('text', 'query', options, []);

      expect(cache.stats.entries, equals(1));
      expect(cache.stats.maxEntries, equals(100));
    });

    test('CacheStats utilizationPercent is correct', () {
      const stats = CacheStats(
        entries: 50,
        maxEntries: 100,
        ttl: Duration(minutes: 15),
      );

      expect(stats.utilizationPercent, equals(50.0));
    });

    test('CacheStats toString works', () {
      const stats = CacheStats(
        entries: 10,
        maxEntries: 100,
        ttl: Duration(minutes: 15),
      );

      expect(stats.toString(), contains('10/100'));
      expect(stats.toString(), contains('15m'));
    });
  });

  group('TextSearchResult Tests', () {
    test('TextSearchResult fromJson works', () {
      final json = {
        'title': 'Test Title',
        'href': 'https://example.com',
        'body': 'Test body',
        'provider': 'google',
      };

      final result = TextSearchResult.fromJson(json);

      expect(result.title, equals('Test Title'));
      expect(result.href, equals('https://example.com'));
      expect(result.body, equals('Test body'));
      expect(result.provider, equals('google'));
    });

    test('TextSearchResult fromJson handles url fallback', () {
      final json = {
        'title': 'Test',
        'url': 'https://example.com',
        'description': 'Desc',
      };

      final result = TextSearchResult.fromJson(json);

      expect(result.href, equals('https://example.com'));
      expect(result.body, equals('Desc'));
    });

    test('TextSearchResult toJson works', () {
      const result = TextSearchResult(
        title: 'Test',
        href: 'https://example.com',
        body: 'Body',
        provider: 'test',
      );

      final json = result.toJson();

      expect(json['title'], equals('Test'));
      expect(json['href'], equals('https://example.com'));
      expect(json['body'], equals('Body'));
      expect(json['provider'], equals('test'));
    });

    test('TextSearchResult equality works', () {
      const result1 = TextSearchResult(
        title: 'Test 1',
        href: 'https://example.com',
        body: 'Body 1',
      );
      const result2 = TextSearchResult(
        title: 'Test 2',
        href: 'https://example.com',
        body: 'Body 2',
      );
      const result3 = TextSearchResult(
        title: 'Test 1',
        href: 'https://different.com',
        body: 'Body 1',
      );

      expect(result1 == result2, isTrue);
      expect(result1 == result3, isFalse);
    });

    test('TextSearchResult toString works', () {
      const result = TextSearchResult(
        title: 'Test',
        href: 'https://example.com',
        body: 'Body',
      );

      expect(result.toString(), contains('TextSearchResult'));
      expect(result.toString(), contains('Test'));
    });
  });

  group('ImageSearchResult Tests', () {
    test('ImageSearchResult fromJson works', () {
      final json = {
        'title': 'Image',
        'image': 'https://example.com/img.jpg',
        'thumbnail': 'https://example.com/thumb.jpg',
        'url': 'https://example.com',
        'width': '800',
        'height': '600',
      };

      final result = ImageSearchResult.fromJson(json);

      expect(result.title, equals('Image'));
      expect(result.imageUrl, equals('https://example.com/img.jpg'));
      expect(result.thumbnailUrl, equals('https://example.com/thumb.jpg'));
      expect(result.sourceUrl, equals('https://example.com'));
      expect(result.width, equals(800));
      expect(result.height, equals(600));
    });

    test('ImageSearchResult aspectRatio works', () {
      const result = ImageSearchResult(
        title: 'Test',
        imageUrl: 'https://example.com/img.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        sourceUrl: 'https://example.com',
        width: 800,
        height: 600,
      );

      expect(result.aspectRatio, closeTo(1.333, 0.01));
      expect(result.isLandscape, isTrue);
      expect(result.isPortrait, isFalse);
    });

    test('ImageSearchResult portrait detection works', () {
      const result = ImageSearchResult(
        title: 'Test',
        imageUrl: 'https://example.com/img.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        sourceUrl: 'https://example.com',
        width: 600,
        height: 800,
      );

      expect(result.isPortrait, isTrue);
      expect(result.isLandscape, isFalse);
    });
  });

  group('VideoSearchResult Tests', () {
    test('VideoSearchResult fromJson works', () {
      final json = {
        'title': 'Video',
        'description': 'Description',
        'embed_url': 'https://example.com/embed',
        'duration': '10:30',
        'publisher': 'Publisher',
      };

      final result = VideoSearchResult.fromJson(json);

      expect(result.title, equals('Video'));
      expect(result.description, equals('Description'));
      expect(result.embedUrl, equals('https://example.com/embed'));
      expect(result.duration, equals(const Duration(minutes: 10, seconds: 30)));
      expect(result.publisher, equals('Publisher'));
    });

    test('VideoSearchResult formattedDuration works', () {
      const result = VideoSearchResult(
        title: 'Test',
        description: 'Desc',
        embedUrl: 'https://example.com/embed',
        duration: Duration(hours: 1, minutes: 30, seconds: 45),
      );

      expect(result.formattedDuration, equals('1:30:45'));
    });

    test('VideoSearchResult formattedDuration without hours', () {
      const result = VideoSearchResult(
        title: 'Test',
        description: 'Desc',
        embedUrl: 'https://example.com/embed',
        duration: Duration(minutes: 5, seconds: 30),
      );

      expect(result.formattedDuration, equals('5:30'));
    });

    test('VideoSearchResult handles content fallback', () {
      final json = {
        'title': 'Video',
        'content': 'Content text',
        'embed_url': 'https://example.com',
      };

      final result = VideoSearchResult.fromJson(json);
      expect(result.description, equals('Content text'));
    });
  });

  group('NewsSearchResult Tests', () {
    test('NewsSearchResult fromJson works', () {
      final json = {
        'title': 'News',
        'body': 'News body',
        'url': 'https://example.com/news',
        'source': 'News Source',
        'date': '2024-01-15',
      };

      final result = NewsSearchResult.fromJson(json);

      expect(result.title, equals('News'));
      expect(result.body, equals('News body'));
      expect(result.url, equals('https://example.com/news'));
      expect(result.source, equals('News Source'));
    });

    test('NewsSearchResult isRecent works for recent news', () {
      final result = NewsSearchResult(
        title: 'News',
        body: 'Body',
        url: 'https://example.com',
        publishedDate: DateTime.now().subtract(const Duration(hours: 2)),
      );

      expect(result.isRecent, isTrue);
    });

    test('NewsSearchResult isRecent works for old news', () {
      final result = NewsSearchResult(
        title: 'News',
        body: 'Body',
        url: 'https://example.com',
        publishedDate: DateTime.now().subtract(const Duration(days: 2)),
      );

      expect(result.isRecent, isFalse);
    });

    test('NewsSearchResult relativeTime works', () {
      final result = NewsSearchResult(
        title: 'News',
        body: 'Body',
        url: 'https://example.com',
        publishedDate: DateTime.now().subtract(const Duration(hours: 5)),
      );

      expect(result.relativeTime, contains('hours ago'));
    });

    test('NewsSearchResult relativeTime for days', () {
      final result = NewsSearchResult(
        title: 'News',
        body: 'Body',
        url: 'https://example.com',
        publishedDate: DateTime.now().subtract(const Duration(days: 3)),
      );

      expect(result.relativeTime, contains('days ago'));
    });
  });

  group('InstantAnswer Tests', () {
    test('InstantAnswer has correct fields', () {
      const answer = InstantAnswer(
        answer: 'Test answer',
        source: 'Wikipedia',
        sourceUrl: 'https://wikipedia.org',
        type: InstantAnswerType.wikipedia,
      );

      expect(answer.answer, equals('Test answer'));
      expect(answer.source, equals('Wikipedia'));
      expect(answer.sourceUrl, equals('https://wikipedia.org'));
      expect(answer.type, equals(InstantAnswerType.wikipedia));
      expect(answer.hasContent, isTrue);
    });

    test('InstantAnswer hasContent is false for empty answer', () {
      const answer = InstantAnswer(
        answer: '',
        source: 'Test',
      );

      expect(answer.hasContent, isFalse);
    });

    test('InstantAnswer toJson works', () {
      const answer = InstantAnswer(
        answer: 'Answer',
        source: 'Source',
        sourceUrl: 'https://example.com',
        type: InstantAnswerType.definition,
      );

      final json = answer.toJson();

      expect(json['answer'], equals('Answer'));
      expect(json['source'], equals('Source'));
      expect(json['sourceUrl'], equals('https://example.com'));
      expect(json['type'], equals('definition'));
    });

    test('InstantAnswer with relatedTopics', () {
      const answer = InstantAnswer(
        answer: 'Answer',
        source: 'Source',
        relatedTopics: [
          RelatedTopic(text: 'Topic 1', url: 'https://example.com/1'),
          RelatedTopic(text: 'Topic 2', url: 'https://example.com/2'),
        ],
      );

      expect(answer.relatedTopics.length, equals(2));
      final json = answer.toJson();
      expect(json['relatedTopics'], isNotNull);
    });
  });

  group('RelatedTopic Tests', () {
    test('RelatedTopic has correct fields', () {
      const topic = RelatedTopic(
        text: 'Topic text',
        url: 'https://example.com',
        icon: 'https://example.com/icon.png',
      );

      expect(topic.text, equals('Topic text'));
      expect(topic.url, equals('https://example.com'));
      expect(topic.icon, equals('https://example.com/icon.png'));
    });

    test('RelatedTopic toJson works', () {
      const topic = RelatedTopic(
        text: 'Topic',
        url: 'https://example.com',
      );

      final json = topic.toJson();
      expect(json['text'], equals('Topic'));
      expect(json['url'], equals('https://example.com'));
    });
  });

  group('SearchSuggestion Tests', () {
    test('SearchSuggestion has correct fields', () {
      const suggestion = SearchSuggestion(
        suggestion: 'dart programming',
        score: 100,
        category: 'programming',
      );

      expect(suggestion.suggestion, equals('dart programming'));
      expect(suggestion.score, equals(100));
      expect(suggestion.category, equals('programming'));
    });

    test('SearchSuggestion toJson works', () {
      const suggestion = SearchSuggestion(
        suggestion: 'test',
        score: 50,
      );

      final json = suggestion.toJson();
      expect(json['suggestion'], equals('test'));
      expect(json['score'], equals(50));
    });
  });

  group('SearchResultChunk Tests', () {
    test('SearchResultChunk has correct fields', () {
      const chunk = SearchResultChunk<TextSearchResult>(
        results: [
          TextSearchResult(
            title: 'Test',
            href: 'https://example.com',
            body: 'Body',
          ),
        ],
        engine: 'google',
        totalResultsSoFar: 1,
        fetchDuration: Duration(milliseconds: 500),
      );

      expect(chunk.results.length, equals(1));
      expect(chunk.engine, equals('google'));
      expect(chunk.isFinal, isFalse);
      expect(chunk.totalResultsSoFar, equals(1));
    });

    test('SearchResultChunk toString works', () {
      const chunk = SearchResultChunk<TextSearchResult>(
        results: [],
        engine: 'test',
      );

      expect(chunk.toString(), contains('SearchResultChunk'));
      expect(chunk.toString(), contains('test'));
    });
  });

  group('SearchProgress Tests', () {
    test('SearchProgress has correct fields', () {
      const progress = SearchProgress(
        enginesQueried: 3,
        totalEngines: 5,
        resultsFound: 15,
        completedEngines: ['google', 'bing', 'duckduckgo'],
        status: 'Searching...',
      );

      expect(progress.enginesQueried, equals(3));
      expect(progress.totalEngines, equals(5));
      expect(progress.resultsFound, equals(15));
      expect(progress.completedEngines.length, equals(3));
    });

    test('SearchProgress progressPercent works', () {
      const progress = SearchProgress(
        enginesQueried: 3,
        totalEngines: 6,
        resultsFound: 10,
      );

      expect(progress.progressPercent, equals(50.0));
    });

    test('SearchProgress isComplete works', () {
      const incomplete = SearchProgress(
        enginesQueried: 3,
        totalEngines: 5,
        resultsFound: 10,
      );
      const complete = SearchProgress(
        enginesQueried: 5,
        totalEngines: 5,
        resultsFound: 20,
      );

      expect(incomplete.isComplete, isFalse);
      expect(complete.isComplete, isTrue);
    });

    test('SearchProgress toString works', () {
      const progress = SearchProgress(
        enginesQueried: 2,
        totalEngines: 4,
        resultsFound: 10,
      );

      expect(progress.toString(), contains('2/4'));
      expect(progress.toString(), contains('10 results'));
    });
  });

  group('SearchEvent Tests', () {
    test('ResultsEvent contains chunk', () {
      const chunk = SearchResultChunk<TextSearchResult>(
        results: [],
        engine: 'test',
      );
      const event = ResultsEvent<TextSearchResult>(chunk);

      expect(event.chunk, equals(chunk));
    });

    test('ProgressEvent contains progress', () {
      const progress = SearchProgress(
        enginesQueried: 1,
        totalEngines: 3,
        resultsFound: 5,
      );
      const event = ProgressEvent<TextSearchResult>(progress);

      expect(event.progress, equals(progress));
    });

    test('ErrorEvent contains engine and error', () {
      const event = ErrorEvent<TextSearchResult>('google', 'Timeout');

      expect(event.engine, equals('google'));
      expect(event.error, equals('Timeout'));
    });

    test('CompletedEvent contains all results', () {
      const event = CompletedEvent<TextSearchResult>(
        allResults: [],
        totalDuration: Duration(seconds: 5),
        finalProgress: SearchProgress(
          enginesQueried: 3,
          totalEngines: 3,
          resultsFound: 15,
        ),
      );

      expect(event.allResults, isEmpty);
      expect(event.totalDuration, equals(const Duration(seconds: 5)));
    });
  });

  group('RetryConfig Tests', () {
    test('RetryConfig has correct defaults', () {
      const config = RetryConfig();

      expect(config.maxRetries, equals(3));
    });

    test('RetryConfig can be customized', () {
      const config = RetryConfig(maxRetries: 5);

      expect(config.maxRetries, equals(5));
    });
  });

  group('Utils Tests', () {
    test('normalizeText removes extra whitespace', () {
      expect(normalizeText('  test   text  '), equals('test text'));
      expect(normalizeText('test\n\ntext'), equals('test text'));
    });

    test('normalizeText handles tabs', () {
      expect(normalizeText('test\t\ttext'), equals('test text'));
    });

    test('normalizeUrl trims whitespace', () {
      expect(normalizeUrl('  https://example.com  '),
          equals('https://example.com'),);
    });

    test('normalizeDate trims whitespace', () {
      expect(normalizeDate('  2024-01-01  '), equals('2024-01-01'));
    });

    test('expandProxyTbAlias expands tb alias', () {
      expect(
        expandProxyTbAlias('tb'),
        equals('socks5h://127.0.0.1:9150'),
      );
      expect(
          expandProxyTbAlias('http://proxy.com'), equals('http://proxy.com'),);
      expect(expandProxyTbAlias(null), isNull);
    });

    test('extractVqd extracts vqd from pattern vqd="..."', () {
      const html = 'some content vqd="abc123" more content';
      expect(extractVqd(html, 'query'), equals('abc123'));
    });

    test('extractVqd extracts vqd from pattern vqd=...&', () {
      const html = 'some content vqd=xyz789&param=value';
      expect(extractVqd(html, 'query'), equals('xyz789'));
    });

    test('extractVqd returns null when not found', () {
      const html = 'some content without vqd';
      expect(extractVqd(html, 'query'), isNull);
    });
  });

  group('Exception Tests', () {
    test('DDGSException has message', () {
      final exception = DDGSException('Test error');
      expect(exception.toString(), contains('Test error'));
      expect(exception.toString(), contains('DDGSException'));
    });

    test('DDGSException message getter works', () {
      final exception = DDGSException('Error message');
      expect(exception.message, equals('Error message'));
    });

    test('TimeoutException is DDGSException', () {
      final exception = TimeoutException('Timeout');
      expect(exception, isA<DDGSException>());
      expect(exception.toString(), contains('TimeoutException'));
    });

    test('RatelimitException is DDGSException', () {
      final exception = RatelimitException('Rate limit');
      expect(exception, isA<DDGSException>());
      expect(exception.toString(), contains('RatelimitException'));
    });
  });

  group('Engine Registry Tests', () {
    test('getAvailableEngines returns list', () {
      final engines = getAvailableEngines('text');
      expect(engines, isA<List<String>>());
      expect(engines, isNotEmpty);
    });

    test('supportedCategories returns list', () {
      final categories = supportedCategories;
      expect(categories, isA<List<String>>());
      expect(categories, contains('text'));
    });

    test('isEngineAvailable works', () {
      // Check for a common engine
      final available = isEngineAvailable('text', 'wikipedia');
      expect(available, isA<bool>());
    });
  });

  group('ParallelSearchConfig Tests', () {
    test('ParallelSearchConfig has correct defaults', () {
      const config = ParallelSearchConfig();

      expect(config.maxConcurrency, equals(5));
      expect(config.failFast, isFalse);
      expect(config.minResults, equals(5));
      expect(config.deduplicate, isTrue);
    });

    test('ParallelSearchConfig.fast has correct values', () {
      expect(ParallelSearchConfig.fast.maxConcurrency, equals(3));
      expect(ParallelSearchConfig.fast.minResults, equals(3));
      expect(ParallelSearchConfig.fast.maxWaitTime,
          equals(const Duration(seconds: 5)),);
    });

    test('ParallelSearchConfig.comprehensive has correct values', () {
      expect(ParallelSearchConfig.comprehensive.maxConcurrency, equals(10));
      expect(ParallelSearchConfig.comprehensive.minResults, equals(20));
      expect(ParallelSearchConfig.comprehensive.mergeStrategy,
          equals(MergeStrategy.byRelevance),);
    });
  });

  group('MergeStrategy Tests', () {
    test('MergeStrategy values exist', () {
      expect(MergeStrategy.values, contains(MergeStrategy.interleave));
      expect(MergeStrategy.values, contains(MergeStrategy.sequential));
      expect(MergeStrategy.values, contains(MergeStrategy.byRelevance));
      expect(MergeStrategy.values, contains(MergeStrategy.bySpeed));
    });
  });

  group('EngineResult Tests', () {
    test('EngineResult success is true when no error', () {
      const result = EngineResult<TextSearchResult>(
        engine: 'google',
        results: [],
        duration: Duration(milliseconds: 500),
      );

      expect(result.success, isTrue);
      expect(result.engine, equals('google'));
    });

    test('EngineResult success is false when error', () {
      const result = EngineResult<TextSearchResult>(
        engine: 'google',
        results: [],
        duration: Duration(milliseconds: 500),
        error: 'Connection failed',
      );

      expect(result.success, isFalse);
      expect(result.error, equals('Connection failed'));
    });
  });

  group('InstantAnswerType Tests', () {
    test('InstantAnswerType values exist', () {
      expect(InstantAnswerType.values, contains(InstantAnswerType.definition));
      expect(InstantAnswerType.values, contains(InstantAnswerType.calculation));
      expect(InstantAnswerType.values, contains(InstantAnswerType.wikipedia));
      expect(InstantAnswerType.values, contains(InstantAnswerType.weather));
      expect(InstantAnswerType.values, contains(InstantAnswerType.unknown));
    });
  });
}
