# Contributing to DDGS

Thank you for your interest in contributing to DDGS! This document provides guidelines for contributing to the project.

## Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Kamran1819G/ddgs.git
   cd ddgs
   ```

2. **Install dependencies:**
   ```bash
   dart pub get
   ```

3. **Run tests:**
   ```bash
   dart test
   ```

4. **Run the example:**
   ```bash
   dart run example/example.dart
   ```

## Code Style

This project follows Dart's official style guide and uses the lints package for code analysis.

- Run code analysis:
  ```bash
  dart analyze
  ```

- Format code:
  ```bash
  dart format .
  ```

## Project Structure

```
ddgs/
├── lib/
│   ├── ddgs.dart              # Main library export
│   └── src/
│       ├── ddgs_base.dart     # Core DDGS class
│       ├── base_search_engine.dart
│       ├── http_client.dart
│       ├── results.dart
│       ├── exceptions.dart
│       ├── utils.dart
│       └── engines/
│           ├── engines.dart   # Engine registry
│           ├── bing.dart
│           ├── brave.dart
│           ├── duckduckgo.dart
│           ├── duckduckgo_images.dart
│           ├── duckduckgo_news.dart
│           ├── duckduckgo_videos.dart
│           ├── mojeek.dart
│           ├── wikipedia.dart
│           ├── yahoo.dart
│           └── yandex.dart
├── bin/
│   └── ddgs.dart             # CLI application
├── example/
│   └── example.dart
└── test/
    └── ddgs_test.dart
```

## Adding a New Search Engine

To add a new search engine:

1. Create a new file in `lib/src/engines/` (e.g., `mynewengine.dart`)

2. Implement the `BaseSearchEngine` abstract class:

```dart
import '../base_search_engine.dart';
import '../results.dart';
import '../http_client.dart';

/// MyNewEngine search engine implementation.
class MyNewEngine extends BaseSearchEngine<SearchResult> {
  MyNewEngine(HttpClient client) : super(client);

  @override
  String get name => 'mynewengine';

  @override
  Future<List<SearchResult>> search(
    String query,
    Map<String, dynamic> params,
  ) async {
    // Implement search logic here
    final results = <SearchResult>[];
    
    // Make HTTP request
    final response = await client.get(
      Uri.parse('https://example.com/search?q=$query'),
    );
    
    // Parse response and create SearchResult objects
    // ...
    
    return results;
  }
}
```

3. Register the engine in `lib/src/engines/engines.dart`:

```dart
import 'mynewengine.dart';

final searchEngines = {
  'text': {
    // ... existing engines
    'mynewengine': (HttpClient client) => MyNewEngine(client),
  },
};
```

4. Add tests for the new engine in `test/ddgs_test.dart`

5. Update documentation in `README.md`

## Testing Guidelines

- Write tests for new features
- Ensure all tests pass before submitting PR
- Test with different regions and parameters
- Test error handling and edge cases

Example test:

```dart
test('MyNewEngine returns results', () async {
  final ddgs = DDGS();
  final results = await ddgs.text(
    'test query',
    backend: 'mynewengine',
    maxResults: 5,
  );
  
  expect(results, isNotEmpty);
  expect(results.first, containsPair('title', isNotNull));
  expect(results.first, containsPair('href', isNotNull));
  
  ddgs.close();
});
```

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and code analysis
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### PR Guidelines

- Provide a clear description of changes
- Reference any related issues
- Ensure CI passes
- Update documentation if needed
- Add tests for new features

## Bug Reports

When filing a bug report, please include:

- Dart version
- Operating system
- Steps to reproduce
- Expected behavior
- Actual behavior
- Error messages or stack traces

## Feature Requests

Feature requests are welcome! Please include:

- Clear description of the feature
- Use cases and benefits
- Possible implementation approach

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Help maintain a positive community

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Feel free to open an issue for questions or discussions about contributing.
