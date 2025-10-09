![Dart >= 3.0](https://img.shields.io/badge/dart->=3.0-blue.svg) ![Version](https://img.shields.io/badge/version-0.1.0-green.svg)

# DDGS | Dux Distributed Global Search

A metasearch library that aggregates results from diverse web search services.

## Table of Contents
* [Install](#install)
* [CLI version](#cli-version)
* [Usage](#usage)
* [DDGS class](#ddgs-class)
* [Proxy](#proxy)
* [Exceptions](#exceptions)
* [Features](#features)

## Install

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ddgs: ^0.1.0
```

Or install from command line:

```bash
dart pub add ddgs
```

Or run directly from source:

```bash
dart pub get
```

## CLI version

### Installation & Testing

First, get dependencies:
```bash
dart pub get
```

Run the CLI tool:
```bash
dart run ddgs --help
```

### CLI Examples

**1. Text search (recommended backend):**
```bash
# Basic search with DuckDuckGo (most reliable)
dart run ddgs text -q 'Dart programming' -m 5 -b duckduckgo

# With JSON output
dart run ddgs text -q 'Dart programming' -m 5 -b duckduckgo --json

# Search with region and safe search
dart run ddgs text -q 'Dart programming' -r us-en -s on -m 5 -b duckduckgo
```

**2. News search:**
```bash
# Recent technology news
dart run ddgs news -q 'technology' -r us-en -m 10 -t d -b duckduckgo
```

**3. Image search with JSON output:**
```bash
# Save images to JSON file
dart run ddgs images -q 'nature' -m 10 -b duckduckgo --json -o results.json
```

**4. Video search:**
```bash
# Find video tutorials
dart run ddgs videos -q 'flutter tutorial' -m 10 -b duckduckgo
```

**5. Save to file:**
```bash
# Search and save results
dart run ddgs text -q 'machine learning' -m 20 -b duckduckgo -o output.json --json
```

### Quick Testing

```bash
# Quick functional test (should return results immediately)
dart run ddgs text -q "Dart programming" -m 3 -b duckduckgo

# Verify JSON output works
dart run ddgs text -q "test" -m 2 -b duckduckgo --json

# Test image search
dart run ddgs images -q "sunset" -m 5 -b duckduckgo --json
```

### Running Unit Tests

```bash
# Run all tests
dart test

# Run with verbose output
dart test --reporter=expanded

# Run specific test file
dart test test/ddgs_test.dart

# Run tests with coverage
dart test --coverage=coverage
```

### Troubleshooting

**No results?** Some search engines (Bing, Yahoo) have anti-scraping measures. Always use `--backend duckduckgo` for reliable results.

**Command hangs?** Reduce `--max-results` or use `timeout 30 dart run ddgs ...`

See [TESTING.md](TESTING.md) for detailed troubleshooting guide.

## Usage

### Basic Example

```dart
import 'package:ddgs/ddgs.dart';

void main() async {
  final ddgs = DDGS();

  try {
    // Text search with DuckDuckGo (recommended)
    final results = await ddgs.text(
      'Dart programming',
      maxResults: 5,
      backend: 'duckduckgo',
    );
    
    for (final result in results) {
      print('Title: ${result['title']}');
      print('URL: ${result['href']}');
      print('Description: ${result['body']}');
      print('---');
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
  // Create DDGS instance with custom settings
  final ddgs = DDGS(
    proxy: 'socks5h://127.0.0.1:9150', // Optional proxy
    timeout: Duration(seconds: 10),      // Request timeout
    verify: true,                         // Verify SSL certificates
  );

  try {
    // Text search with options
    final textResults = await ddgs.text(
      'machine learning',
      region: 'us-en',
      safesearch: 'moderate',
      timelimit: 'w', // Last week
      maxResults: 10,
      page: 1,
      backend: 'google,duckduckgo',
    );

    // Image search
    final imageResults = await ddgs.images(
      'beautiful landscapes',
      maxResults: 20,
    );

    // Video search
    final videoResults = await ddgs.videos(
      'tutorial dart',
      maxResults: 10,
    );

    // News search
    final newsResults = await ddgs.news(
      'climate change',
      timelimit: 'd', // Last day
      maxResults: 15,
    );

    // Books search
    final bookResults = await ddgs.books(
      'science fiction',
      maxResults: 10,
    );
    
  } finally {
    ddgs.close();
  }
}
```

## DDGS class

```dart
class DDGS {
  DDGS({
    String? proxy,      // Proxy URL (http, https, socks5)
    Duration? timeout,  // Request timeout
    bool verify = true, // Verify SSL certificates
  });
}
```

### Methods

#### 1. text()

Text search across multiple search engines.

```dart
Future<List<Map<String, dynamic>>> text(
  String query, {
  String region = 'us-en',
  String safesearch = 'moderate',
  String? timelimit,
  int? maxResults = 10,
  int page = 1,
  String backend = 'auto',
})
```

**Parameters:**
- `query`: Search query string
- `region`: Region code (e.g., 'us-en', 'uk-en', 'de-de')
- `safesearch`: Safe search filter ('on', 'moderate', 'off')
- `timelimit`: Time filter ('d' = day, 'w' = week, 'm' = month, 'y' = year)
- `maxResults`: Maximum number of results to return
- `page`: Page number for pagination
- `backend`: Search engines to use (comma-separated or 'auto')

**Returns:** List of maps containing:
- `title`: Result title
- `href`: Result URL
- `body`: Result description/snippet

#### 2. images()

Image search.

```dart
Future<List<Map<String, dynamic>>> images(
  String query, {
  String region = 'us-en',
  String safesearch = 'moderate',
  String? timelimit,
  int? maxResults = 10,
  int page = 1,
  String backend = 'auto',
})
```

**Returns:** List of maps containing:
- `title`: Image title
- `image`: Image URL
- `thumbnail`: Thumbnail URL
- `url`: Source page URL
- `height`, `width`: Image dimensions
- `source`: Source website

#### 3. videos()

Video search.

```dart
Future<List<Map<String, dynamic>>> videos(
  String query, {
  String region = 'us-en',
  String safesearch = 'moderate',
  String? timelimit,
  int? maxResults = 10,
  int page = 1,
  String backend = 'auto',
})
```

#### 4. news()

News search.

```dart
Future<List<Map<String, dynamic>>> news(
  String query, {
  String region = 'us-en',
  String safesearch = 'moderate',
  String? timelimit,
  int? maxResults = 10,
  int page = 1,
  String backend = 'auto',
})
```

**Returns:** List of maps containing:
- `date`: Publication date
- `title`: Article title
- `body`: Article snippet
- `url`: Article URL
- `image`: Article image URL
- `source`: News source

#### 5. books()

Books search.

```dart
Future<List<Map<String, dynamic>>> books(
  String query, {
  String region = 'us-en',
  String safesearch = 'moderate',
  int? maxResults = 10,
  int page = 1,
  String backend = 'auto',
})
```

## Proxy

DDGS supports HTTP, HTTPS, and SOCKS5 proxies:

```dart
// HTTP proxy
final ddgs = DDGS(proxy: 'http://user:pass@proxy.com:8080');

// SOCKS5 proxy
final ddgs = DDGS(proxy: 'socks5h://127.0.0.1:9150');

// Tor Browser shorthand
final ddgs = DDGS(proxy: 'tb'); // Expands to socks5h://127.0.0.1:9150
```

## Exceptions

The library defines three exception types:

- `DDGSException`: Base exception class
- `RatelimitException`: Raised when rate limit is exceeded
- `TimeoutException`: Raised when request times out

```dart
try {
  final results = await ddgs.text('query');
} on TimeoutException catch (e) {
  print('Request timed out: $e');
} on RatelimitException catch (e) {
  print('Rate limit exceeded: $e');
} on DDGSException catch (e) {
  print('DDGS error: $e');
}
```

## Features

- ✅ Multi-engine metasearch (aggregates results from multiple search engines)
- ✅ Text, image, video, news, and books search
- ✅ Proxy support (HTTP, HTTPS, SOCKS5)
- ✅ Region and language support
- ✅ Safe search filtering
- ✅ Time-based filtering
- ✅ Result deduplication
- ✅ CLI tool
- ✅ Async/await API
- ✅ Configurable timeout
- ✅ Extensible engine architecture

## Search Operators

| Query example | Result |
| --- | --- |
| cats dogs | Results about cats or dogs |
| "cats and dogs" | Results for exact term "cats and dogs" |
| cats -dogs | Fewer dogs in results |
| cats +dogs | More dogs in results |
| cats filetype:pdf | PDFs about cats |
| dogs site:example.com | Pages about dogs from example.com |
| cats -site:example.com | Pages about cats, excluding example.com |
| intitle:dogs | Page title includes "dogs" |
| inurl:cats | Page URL includes "cats" |

## Regions

Common region codes:
- `us-en` - United States (English)
- `uk-en` - United Kingdom (English)
- `de-de` - Germany (German)
- `fr-fr` - France (French)
- `es-es` - Spain (Spanish)
- `it-it` - Italy (Italian)
- `jp-jp` - Japan (Japanese)
- `cn-zh` - China (Chinese)
- `ru-ru` - Russia (Russian)

## Engines

Available search engines:
- **Text**: Bing, Brave, DuckDuckGo, Mojeek, Wikipedia, Yahoo, Yandex (7 engines)
- **Images**: DuckDuckGo
- **Videos**: DuckDuckGo
- **News**: DuckDuckGo
- **Books**: (To be implemented)

**Note**: Some engines (Bing, Yahoo, Yandex) may have anti-scraping protection. DuckDuckGo is recommended for reliable results.

## License

MIT License

## Disclaimer

This library is for educational purposes only. Respect the terms of service of the search engines you use. The authors are not responsible for any misuse of this library.
