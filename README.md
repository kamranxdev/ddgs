# DDGS - Dux Distributed Global Search

![Dart >= 3.0](https://img.shields.io/badge/dart->=3.0-blue.svg)
![Version](https://img.shields.io/badge/version-0.1.0-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

A professional metasearch library that aggregates results from multiple web search engines including DuckDuckGo, Bing, Brave, and more.

## Features

- 🔍 **Multi-Engine Support**: Search across 10 different search engines
- 🎯 **Specialized Search**: Text, images, videos, and news search capabilities
- 🔒 **Privacy-Focused**: DuckDuckGo as default backend
- 🌐 **Region Support**: Search in different regions and languages
- ⚡ **Async/Await**: Modern asynchronous API
- 🛡️ **Safe Search**: Built-in safe search filtering
- 🔄 **Proxy Support**: HTTP, HTTPS, and SOCKS5 proxy support
- 🚀 **CLI Tool**: Command-line interface included

### Supported Engines

**Text Search:**
- DuckDuckGo (recommended)
- Bing
- Brave
- Mojeek
- Wikipedia
- Yahoo
- Yandex

**Specialized Search:**
- DuckDuckGo Images
- DuckDuckGo Videos
- DuckDuckGo News

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  ddgs: ^0.1.0
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

- 📖 [Documentation](https://github.com/Kamran1819G/ddgs#readme)
- 🐛 [Issue Tracker](https://github.com/Kamran1819G/ddgs/issues)
- 💬 [Discussions](https://github.com/Kamran1819G/ddgs/discussions)

## Roadmap

- [ ] Books search implementation
- [ ] Maps search integration
- [ ] Translations support
- [ ] Enhanced rate limiting
- [ ] More search engines

---

**Note**: Some search engines have anti-scraping measures. DuckDuckGo is recommended as the default backend for reliability.
