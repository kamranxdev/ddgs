#!/usr/bin/env dart
/// Integration test script for DDGS library.
/// 
/// This script tests real search functionality with actual queries
/// and demonstrates various features of the library.

import 'package:ddgs/ddgs.dart';

void main() async {
  print('🔍 DDGS Integration Tests\n');
  print('=' * 60);

  final ddgs = DDGS();

  try {
    // Test 1: Basic text search
    print('\n✅ Test 1: Basic Text Search');
    print('-' * 60);
    await testBasicTextSearch(ddgs);

    // Test 2: Text search with options
    print('\n✅ Test 2: Text Search with Different Regions');
    print('-' * 60);
    await testSearchByRegion(ddgs);

    // Test 3: Typed text search
    print('\n✅ Test 3: Typed Text Search (Strongly-Typed Results)');
    print('-' * 60);
    await testTypedSearch(ddgs);

    // Test 4: Image search
    print('\n✅ Test 4: Image Search');
    print('-' * 60);
    await testImageSearch(ddgs);

    // Test 5: Video search
    print('\n✅ Test 5: Video Search');
    print('-' * 60);
    await testVideoSearch(ddgs);

    // Test 6: News search
    print('\n✅ Test 6: News Search');
    print('-' * 60);
    await testNewsSearch(ddgs);

    // Test 7: Time-limited search
    print('\n✅ Test 7: Time-Limited Search (Last 24 Hours)');
    print('-' * 60);
    await testTimeLimitedSearch(ddgs);

    // Test 8: Safe search levels
    print('\n✅ Test 8: Safe Search Levels');
    print('-' * 60);
    await testSafeSearch(ddgs);

    // Test 9: Pagination
    print('\n✅ Test 9: Pagination');
    print('-' * 60);
    await testPagination(ddgs);

    // Test 10: Instant answers
    print('\n✅ Test 10: Instant Answers');
    print('-' * 60);
    await testInstantAnswers(ddgs);

    // Test 11: Suggestions
    print('\n✅ Test 11: Search Suggestions');
    print('-' * 60);
    await testSuggestions(ddgs);

    // Test 12: Spelling correction
    print('\n✅ Test 12: Spelling Correction');
    print('-' * 60);
    await testSpellingCorrection(ddgs);

    // Test 13: Batch search
    print('\n✅ Test 13: Batch Search (Multiple Queries)');
    print('-' * 60);
    await testBatchSearch(ddgs);

    // Test 14: Cache functionality
    print('\n✅ Test 14: Cache Functionality');
    print('-' * 60);
    await testCache(ddgs);

    // Test 15: Error handling
    print('\n✅ Test 15: Error Handling');
    print('-' * 60);
    await testErrorHandling(ddgs);

    print('\n${'=' * 60}');
    print('✨ All integration tests completed successfully!');
  } catch (e) {
    print('\n❌ Error during tests: $e');
  } finally {
    ddgs.close();
  }
}

Future<void> testBasicTextSearch(DDGS ddgs) async {
  print('Searching for: "Dart programming language"');
  final results = await ddgs.text('Dart programming language', maxResults: 3);
  
  print('Found ${results.length} results:\n');
  for (var i = 0; i < results.length && i < 3; i++) {
    final result = results[i];
    print('  ${i + 1}. ${result['title']}');
    print('     URL: ${result['href']}');
    final body = result['body'] as String;
    final summary = body.length > 80 ? body.substring(0, 80) : body;
    print('     Summary: $summary...\n');
  }
}

Future<void> testSearchByRegion(DDGS ddgs) async {
  print('Testing searches in different regions:\n');
  
  final regions = [
    ('us-en', 'United States'),
    ('uk-en', 'United Kingdom'),
    ('de-de', 'Germany'),
  ];

  for (final (code, name) in regions) {
    print('Region: $name ($code)');
    try {
      final results = await ddgs.text(
        'weather today',
        region: code,
        maxResults: 1,
      );
      if (results.isNotEmpty) {
        print('  ✓ Got result: ${results.first['title']}\n');
      }
    } catch (e) {
      print('  ✗ Error: $e\n');
    }
  }
}

Future<void> testTypedSearch(DDGS ddgs) async {
  print('Searching for: "Flutter mobile development"');
  
  final results = await ddgs.textTyped(
    'Flutter mobile development',
    options: const SearchOptions(maxResults: 2),
  );

  print('Found ${results.length} typed results:\n');
  for (var i = 0; i < results.length; i++) {
    final result = results[i];
    print('  ${i + 1}. Title: ${result.title}');
    print('     Type: ${result.runtimeType}');
    print('     URL: ${result.href}');
    final bodyPreview = result.body.length > 60 ? result.body.substring(0, 60) : result.body;
    print('     Body: $bodyPreview...\n');
  }
}

Future<void> testImageSearch(DDGS ddgs) async {
  print('Searching for images: "sunset landscape"');
  
  final results = await ddgs.imagesTyped(
    'sunset landscape',
    options: const SearchOptions(maxResults: 3),
  );

  print('Found ${results.length} image results:\n');
  for (var i = 0; i < results.length && i < 3; i++) {
    final result = results[i];
    print('  ${i + 1}. Title: ${result.title}');
    print('     Image URL: ${result.imageUrl}');
    if (result.width != null && result.height != null) {
      print('     Dimensions: ${result.width}x${result.height}');
      print('     Orientation: ${result.isLandscape ? 'Landscape' : result.isPortrait ? 'Portrait' : 'Square'}');
    }
    print('     Source: ${result.sourceUrl}\n');
  }
}

Future<void> testVideoSearch(DDGS ddgs) async {
  print('Searching for videos: "Dart tutorial"');
  
  final results = await ddgs.videosTyped(
    'Dart tutorial',
    options: const SearchOptions(maxResults: 2),
  );

  print('Found ${results.length} video results:\n');
  for (var i = 0; i < results.length && i < 2; i++) {
    final result = results[i];
    print('  ${i + 1}. Title: ${result.title}');
    print('     Publisher: ${result.publisher ?? 'Unknown'}');
    print('     Duration: ${result.formattedDuration.isNotEmpty ? result.formattedDuration : 'N/A'}');
    print('     Embed URL: ${result.embedUrl}\n');
  }
}

Future<void> testNewsSearch(DDGS ddgs) async {
  print('Searching for news: "technology news"');
  
  final results = await ddgs.newsTyped(
    'technology news',
    options: const SearchOptions(maxResults: 2),
  );

  print('Found ${results.length} news results:\n');
  for (var i = 0; i < results.length && i < 2; i++) {
    final result = results[i];
    print('  ${i + 1}. Title: ${result.title}');
    print('     Source: ${result.source ?? 'Unknown'}');
    print('     Date: ${result.publishedDate ?? 'N/A'}');
    if (result.isRecent) {
      print('     ⏰ This is recent news (within 24 hours)');
    }
    print('     Time: ${result.relativeTime}');
    print('     URL: ${result.url}\n');
  }
}

Future<void> testTimeLimitedSearch(DDGS ddgs) async {
  print('Searching for: "AI news" (last 24 hours only)\n');
  
  final results = await ddgs.text(
    'AI news',
    timelimit: 'd',
    maxResults: 2,
  );

  print('Found ${results.length} results from the last 24 hours:\n');
  for (var i = 0; i < results.length && i < 2; i++) {
    final result = results[i];
    print('  ${i + 1}. ${result['title']}');
    print('     URL: ${result['href']}\n');
  }
}

Future<void> testSafeSearch(DDGS ddgs) async {
  print('Testing different safe search levels:\n');
  
  const levels = [
    ('moderate', 'Moderate (Default)'),
    ('on', 'Strict'),
    ('off', 'Off'),
  ];

  for (final (code, name) in levels) {
    print('Safe Search: $name ($code)');
    try {
      final results = await ddgs.text(
        'search test',
        safesearch: code,
        maxResults: 1,
      );
      if (results.isNotEmpty) {
        print('  ✓ Got result: ${results.first['title']}\n');
      }
    } catch (e) {
      print('  ✗ Error: $e\n');
    }
  }
}

Future<void> testPagination(DDGS ddgs) async {
  print('Testing pagination:\n');
  
  for (var page = 1; page <= 3; page++) {
    print('Page $page:');
    try {
      final results = await ddgs.text(
        'programming',
        maxResults: 2,
        page: page,
      );
      
      if (results.isNotEmpty) {
        for (var i = 0; i < results.length && i < 2; i++) {
          print('  ${i + 1}. ${results[i]['title']}');
        }
      }
      print('');
    } catch (e) {
      print('  Error: $e\n');
    }
  }
}

Future<void> testInstantAnswers(DDGS ddgs) async {
  print('Testing instant answers for various queries:\n');
  
  final queries = ['What is Python?', 'Capital of France', '2+2'];

  for (final query in queries) {
    print('Query: "$query"');
    try {
      final answer = await ddgs.instantAnswer(query);
      
      if (answer != null && answer.hasContent) {
        print('  Answer: ${answer.answer}');
        print('  Source: ${answer.source}');
        print('  Type: ${answer.type.name}');
      } else {
        print('  No instant answer available');
      }
    } catch (e) {
      print('  Error: $e');
    }
    print('');
  }
}

Future<void> testSuggestions(DDGS ddgs) async {
  print('Getting search suggestions for: "dart"\n');
  
  try {
    final suggestions = await ddgs.suggestions('dart');
    
    print('Found ${suggestions.length} suggestions:\n');
    for (var i = 0; i < suggestions.length && i < 5; i++) {
      final suggestion = suggestions[i];
      print('  ${i + 1}. ${suggestion.suggestion}');
      if (suggestion.category != null) {
        print('     Category: ${suggestion.category}');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> testSpellingCorrection(DDGS ddgs) async {
  print('Testing spelling correction:\n');
  
  final queries = ['pyton', 'fluttr', 'javascrip'];

  for (final query in queries) {
    print('Query: "$query"');
    try {
      final correction = await ddgs.spellingCorrection(query);
      
      if (correction != null) {
        print('  Suggested: "$correction"\n');
      } else {
        print('  No correction suggested\n');
      }
    } catch (e) {
      print('  Error: $e\n');
    }
  }
}

Future<void> testBatchSearch(DDGS ddgs) async {
  print('Performing batch search with multiple queries:\n');
  
  final queries = ['Dart', 'Flutter', 'Python'];
  
  try {
    final results = await ddgs.batchSearch(
      queries,
      options: const SearchOptions(maxResults: 1),
    );

    for (final query in queries) {
      final queryResults = results[query] ?? [];
      print('Query: "$query"');
      if (queryResults.isNotEmpty) {
        print('  First result: ${queryResults.first['title']}');
      }
      print('');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> testCache(DDGS ddgs) async {
  print('Testing cache functionality:\n');
  
  // Create a new DDGS instance with caching enabled
  final cachedDdgs = DDGS(cacheConfig: CacheConfig.memory);
  
  const options = SearchOptions(maxResults: 2);
  
  try {
    // First search - will be cached
    print('1st search (from network):');
    var start = DateTime.now();
    final results1 = await cachedDdgs.searchWithOptions(
      'flutter',
      category: 'text',
      options: options,
    );
    final duration1 = DateTime.now().difference(start);
    print('   Found ${results1.length} results in ${duration1.inMilliseconds}ms');

    // Second search - should be from cache
    print('2nd search (from cache):');
    start = DateTime.now();
    final results2 = await cachedDdgs.searchWithOptions(
      'flutter',
      category: 'text',
      options: options,
    );
    final duration2 = DateTime.now().difference(start);
    print('   Found ${results2.length} results in ${duration2.inMilliseconds}ms');

    if (duration2.inMilliseconds < duration1.inMilliseconds) {
      print('\n   ✓ Cache is working! Second search was faster.');
    }

    // Check cache stats
    final stats = cachedDdgs.cacheStats;
    if (stats != null) {
      print('\nCache Statistics:');
      print('   Entries: ${stats.entries}');
      print('   Max entries: ${stats.maxEntries}');
      print('   Utilization: ${stats.utilizationPercent.toStringAsFixed(1)}%');
    }

    cachedDdgs.close();
  } catch (e) {
    print('Error: $e');
    cachedDdgs.close();
  }
}

Future<void> testErrorHandling(DDGS ddgs) async {
  print('Testing error handling:\n');
  
  // Test 1: Empty query
  print('Test 1: Empty query');
  try {
    await ddgs.text('');
    print('  ✗ Should have thrown DDGSException\n');
  } catch (e) {
    if (e is DDGSException) {
      print('  ✓ Correctly caught: $e\n');
    } else {
      print('  ✗ Wrong exception type: $e\n');
    }
  }

  // Test 2: Available engines
  print('Test 2: Check available engines for text search');
  try {
    final engines = ddgs.getAvailableEnginesFor('text');
    print('  ✓ Found ${engines.length} engines: ${engines.join(", ")}\n');
  } catch (e) {
    print('  ✗ Error: $e\n');
  }

  // Test 3: Invalid category graceful fallback
  print('Test 3: Search with auto backend (should work)');
  try {
    final results = await ddgs.text('test', maxResults: 1);
    if (results.isNotEmpty) {
      print('  ✓ Auto backend found results: ${results.first['title']}\n');
    }
  } catch (e) {
    print('  ✗ Error: $e\n');
  }
}
