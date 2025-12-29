# DDGS - Dux Distributed Global Search

![Dart >= 3.0](https://img.shields.io/badge/dart->=3.0-blue.svg)
![Version](https://img.shields.io/badge/version-0.2.0-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

A professional metasearch library that aggregates results from multiple web search engines including DuckDuckGo, Google, Bing, Brave, and more.

## Features

- 🔍 **Multi-Engine Support**: Search across 14+ different search engines
- 🎯 **Specialized Search**: Text, images, videos, and news search capabilities
- 🔒 **Privacy-Focused**: DuckDuckGo as default backend
- 🌐 **Region Support**: Search in different regions and languages
- ⚡ **Async/Await**: Modern asynchronous API
- 🛡️ **Safe Search**: Built-in safe search filtering
- 🔄 **Proxy Support**: HTTP, HTTPS, and SOCKS5 proxy support
- 🚀 **CLI Tool**: Command-line interface included
- 📦 **Type-Safe Results**: Strongly-typed result classes
- 💾 **Result Caching**: Optional caching with TTL support
- 🔁 **Rate Limiting**: Built-in rate limiter to prevent API abuse
- 🎯 **Instant Answers**: Direct answers, definitions, and calculations
- 📝 **Search Suggestions**: Autocomplete support
- ⚡ **Parallel Search**: Batch multiple queries concurrently

### Supported Engines

**Text Search:**
- DuckDuckGo (recommended)
- Google
- Bing
- Brave
- Ecosia (eco-friendly)
- Qwant (privacy-focused)
- StartPage (Google proxy)
- Mojeek
- Wikipedia
- Yahoo
- Yandex

**Image Search:**
- DuckDuckGo Images
- Google Images
- Qwant Images

**Video Search:**
- DuckDuckGo Videos

**News Search:**
- DuckDuckGo News
- Qwant News

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  ddgs: ^0.1.3
```

Or install via command line:

```bash
dart pub add ddgs
```

## Quick Start

### Basic Usage

```dart
import 'package:ddgs/ddgs.dart';

void main() async {
  final ddgs = DDGS();

  try {
    final results = await ddgs.text(
      'Dart programming',
      maxResults: 5,
      backend: 'duckduckgo',
    );
    
    for (final result in results) {
      print('${result['title']}: ${result['href']}');
    }
  } finally {
    ddgs.close();
  }
}
```

### Advanced Usage

```dart
import 'package:ddgs/ddgs.dart';

void main() async {
  // Configure with custom settings
  final ddgs = DDGS(
    proxy: 'http://proxy.example.com:8080',
    timeout: Duration(seconds: 10),
    verify: true,
  );

  try {
    // Text search with filters
    final textResults = await ddgs.text(
      'machine learning',
      region: 'us-en',
      safesearch: 'moderate',
      timelimit: 'w', // Last week
      maxResults: 10,
      backend: 'duckduckgo',
    );

    // Image search
    final images = await ddgs.images('nature', maxResults: 20);

    // Video search
    final videos = await ddgs.videos('tutorial', maxResults: 10);

    // News search
    final news = await ddgs.news('technology', timelimit: 'd', maxResults: 15);
    
  } finally {
    ddgs.close();
  }
}
```

## CLI Usage

### Installation

```bash
dart pub get
```

### Basic Commands

```bash
# Text search
dart run ddgs text -q "Dart programming" -m 5 -b duckduckgo

# With JSON output
dart run ddgs text -q "Flutter" -m 5 -b duckduckgo --json

# Image search
dart run ddgs images -q "sunset" -m 10 -b duckduckgo

# Video search
dart run ddgs videos -q "tutorial" -m 5 -b duckduckgo

# News search
dart run ddgs news -q "technology" -m 10 -b duckduckgo

# Save to file
dart run ddgs text -q "AI" -m 20 -b duckduckgo -o results.json --json
```

### CLI Options

```
Options:
  -q, --query              Search query (required)
  -m, --max-results        Maximum number of results (default: 10)
  -b, --backend            Search backend (default: duckduckgo)
  -r, --region             Search region (e.g., us-en, wt-wt)
  -s, --safesearch         Safe search: on, moderate, off
  -t, --timelimit          Time limit: d (day), w (week), m (month), y (year)
  -o, --output             Output file path
      --json               Output in JSON format
  -h, --help               Show help
```

## API Reference

### DDGS Class

```dart
// Constructor
DDGS({
  String? proxy,
  Duration? timeout,
  bool verify = true,
});

// Text Search
Future<List<Map<String, dynamic>>> text(
  String query, {
  String? region,
  String? safesearch,
  String? timelimit,
  int? maxResults,
  int? page,
  String backend = 'duckduckgo',
});

// Image Search
Future<List<Map<String, dynamic>>> images(
  String query, {
  String? region,
  String? safesearch,
  String? timelimit,
  String? size,
  String? color,
  String? type,
  String? layout,
  String? license,
  int? maxResults,
});

// Video Search
Future<List<Map<String, dynamic>>> videos(
  String query, {
  String? region,
  String? safesearch,
  String? timelimit,
  String? resolution,
  String? duration,
  String? license,
  int? maxResults,
});

// News Search
Future<List<Map<String, dynamic>>> news(
  String query, {
  String? region,
  String? safesearch,
  String? timelimit,
  int? maxResults,
});

// Close HTTP client
void close();
```

## Testing

```bash
# Run all tests
dart test

# Run with verbose output
dart test --reporter=expanded

# Run with coverage
dart test --coverage=coverage

# Analyze code
dart analyze

# Format code
dart format .
```

## Exception Handling

```dart
import 'package:ddgs/ddgs.dart';

void main() async {
  final ddgs = DDGS();

  try {
    final results = await ddgs.text('query');
  } on RatelimitException catch (e) {
    print('Rate limit exceeded: $e');
  } on TimeoutException catch (e) {
    print('Request timeout: $e');
  } on DDGSException catch (e) {
    print('Search error: $e');
  } finally {
    ddgs.close();
  }
}
```

## Configuration

### Proxy Support

```dart
// HTTP Proxy
final ddgs = DDGS(proxy: 'http://proxy.example.com:8080');

// HTTPS Proxy
final ddgs = DDGS(proxy: 'https://proxy.example.com:8443');

// SOCKS5 Proxy (for Tor, etc.)
final ddgs = DDGS(proxy: 'socks5h://127.0.0.1:9150');
```

### Timeout Configuration

```dart
final ddgs = DDGS(timeout: Duration(seconds: 30));
```

### SSL Verification

```dart
// Disable SSL verification (not recommended)
final ddgs = DDGS(verify: false);
```

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Development Setup

1. Clone the repository
2. Install dependencies: `dart pub get`
3. Run tests: `dart test`
4. Format code: `dart format .`
5. Analyze: `dart analyze`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Original Python implementation inspiration
- DuckDuckGo for privacy-focused search
- All contributors to this project

## Support

- 📖 [Documentation](https://github.com/kamranxdev/ddgs#readme)
- 🐛 [Issue Tracker](https://github.com/kamranxdev/ddgs/issues)
- 💬 [Discussions](https://github.com/kamranxdev/ddgs/discussions)

## Roadmap

- [x] Books search implementation
- [x] Enhanced rate limiting
- [x] More search engines (Google, Ecosia, Qwant, StartPage)
- [x] Type-safe result classes
- [x] Result caching
- [x] Instant answers API
- [x] Search suggestions/autocomplete
- [x] Parallel batch search
- [ ] Maps search integration
- [ ] Translations support
- [ ] Streaming results API

---

## Advanced Features

### Type-Safe Results

```dart
import 'package:ddgs/ddgs.dart';

void main() async {
  final ddgs = DDGS();

  try {
    // Get strongly-typed results
    final results = await ddgs.textTyped('Dart programming');
    
    for (final result in results) {
      // IDE autocompletion works!
      print('Title: ${result.title}');
      print('URL: ${result.href}');
      print('Body: ${result.body}');
    }
  } finally {
    ddgs.close();
  }
}
```

### Search Options

```dart
import 'package:ddgs/ddgs.dart';

void main() async {
  final ddgs = DDGS();

  // Create custom search options
  final options = SearchOptions(
    region: SearchRegion.ukEnglish,
    safeSearch: SafeSearchLevel.strict,
    timeLimit: TimeLimit.week,
    maxResults: 20,
  );

  // Or use presets
  final quickResults = await ddgs.textTyped(
    'Flutter widgets',
    options: SearchOptions.quick,
  );

  final comprehensiveResults = await ddgs.textTyped(
    'Machine learning',
    options: SearchOptions.comprehensive,
  );

  ddgs.close();
}
```

### Instant Answers

```dart
import 'package:ddgs/ddgs.dart';

void main() async {
  final ddgs = DDGS();

  // Get instant answer (definitions, calculations, etc.)
  final answer = await ddgs.instantAnswer('what is the speed of light');
  if (answer != null && answer.hasContent) {
    print('Answer: ${answer.answer}');
    print('Source: ${answer.source}');
    if (answer.abstract != null) {
      print('Abstract: ${answer.abstract}');
    }
  }

  // Get search suggestions
  final suggestions = await ddgs.suggestions('flutter w');
  for (final suggestion in suggestions) {
    print('Suggestion: ${suggestion.suggestion}');
  }

  // Get spelling correction
  final correction = await ddgs.spellingCorrection('fluter programing');
  if (correction != null) {
    print('Did you mean: $correction');
  }

  ddgs.close();
}
```

### Result Caching

```dart
import 'package:ddgs/ddgs.dart';

void main() async {
  // Enable caching with 15-minute TTL
  final ddgs = DDGS(
    cacheConfig: CacheConfig(
      enabled: true,
      ttl: Duration(minutes: 15),
      maxEntries: 100,
    ),
  );

  // First search - fetches from network
  final results1 = await ddgs.textTyped('Dart programming');

  // Second identical search - returns from cache
  final results2 = await ddgs.textTyped('Dart programming');

  // Check cache stats
  print('Cache stats: ${ddgs.cacheStats}');

  // Clear cache if needed
  ddgs.clearCache();

  ddgs.close();
}
```

### Batch/Parallel Search

```dart
import 'package:ddgs/ddgs.dart';

void main() async {
  final ddgs = DDGS();

  // Search multiple queries in parallel
  final results = await ddgs.batchSearch(
    ['Dart programming', 'Flutter widgets', 'Pub packages'],
    category: 'text',
    options: SearchOptions(maxResults: 5),
    maxConcurrency: 3,
  );

  for (final entry in results.entries) {
    print('Query: ${entry.key}');
    print('Results: ${entry.value.length}');
  }

  ddgs.close();
}
```

### Rate Limiting & Retry

```dart
import 'package:ddgs/ddgs.dart';

void main() async {
  final ddgs = DDGS(
    // Limit requests to prevent being blocked
    maxRequestsPerSecond: 5,
    
    // Configure retry behavior
    retryConfig: RetryConfig(
      maxRetries: 3,
      baseDelay: Duration(milliseconds: 500),
      exponentialBackoff: true,
    ),
  );

  // Your searches are now rate-limited and will retry on failure
  final results = await ddgs.text('search query');

  ddgs.close();
}
```

### Available Engines Query

```dart
import 'package:ddgs/ddgs.dart';

void main() {
  // Get all available engines for a category
  final textEngines = getAvailableEngines('text');
  print('Text engines: $textEngines');

  // Get all supported categories
  print('Categories: $supportedCategories');

  // Check if an engine is available
  if (isEngineAvailable('text', 'google')) {
    print('Google search is available!');
  }
}
```

---

## Testing

This package includes comprehensive test coverage:

### Unit Tests
123 unit tests covering all public APIs and functionality:
```bash
dart test
```

Run specific test groups:
```bash
dart test -n "DDGS Tests"
dart test -n "Configuration"
dart test -n "Result Cache"
```

### Integration Tests
15 test groups executing real-world queries against actual search engines:
```bash
dart bin/integration_test.dart
```

Tests include:
- Text search across multiple engines
- Image, video, and news search
- Regional and language-specific searches
- Instant answers and suggestions
- Pagination and batch queries
- Caching performance (100-500x speedup verified)
- Error handling and resilience

### Documentation
- [TESTING_SUMMARY.md](TESTING_SUMMARY.md) - Complete test overview
- [INTEGRATION_TEST_REPORT.md](INTEGRATION_TEST_REPORT.md) - Detailed integration test results
- [QUICK_TEST_GUIDE.md](QUICK_TEST_GUIDE.md) - Quick reference guide

### Example Scripts
Educational examples showing common patterns:
```bash
dart bin/simple_example.dart    # 5 basic examples
dart bin/integration_test.dart  # Full integration tests
```

---

**Note**: Some search engines have anti-scraping measures. DuckDuckGo is recommended as the default backend for reliability.
