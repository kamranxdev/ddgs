# Testing Guide

## CLI Testing

### Quick Test Commands

```bash
# 1. Text search with DuckDuckGo (most reliable)
dart run ddgs text -q "Dart programming" -m 5 -b duckduckgo

# 2. Text search with JSON output
dart run ddgs text -q "Flutter framework" -m 5 -b duckduckgo --json

# 3. Image search
dart run ddgs images -q "sunset" -m 10 -b duckduckgo

# 4. Video search
dart run ddgs videos -q "dart tutorial" -m 5 -b duckduckgo

# 5. News search
dart run ddgs news -q "technology" -m 10 -b duckduckgo

# 6. Save results to file
dart run ddgs text -q "programming" -m 10 -b duckduckgo -o results.json --json
```

### Expected Output

#### Text Search
```bash
❯ dart run ddgs text -q "Dart programming" -m 3 -b duckduckgo

1. ======================================================================
title: Dart programming language
href: dart.dev
body: Dart is an approachable, portable, and productive language for high-quality apps on any platform.

2. ======================================================================
title: Dart Tutorial - GeeksforGeeks
href: www.geeksforgeeks.org/dart/dart-tutorial/
body: Dart is an open-source general-purpose programming language...

3. ======================================================================
...
```

#### JSON Output
```bash
❯ dart run ddgs text -q "test" -m 2 -b duckduckgo --json

[{"title":"...","href":"...","body":"..."},{"title":"...","href":"...","body":"..."}]
```

## Running Unit Tests

```bash
# Run all tests
dart test

# Run tests with verbose output
dart test --reporter expanded

# Run specific test file
dart test test/ddgs_test.dart
```

## Troubleshooting

### No Results Returned

**Problem**: Command runs but returns empty results `[]`

**Causes**:
1. **Bing/Yahoo anti-scraping**: Some search engines block automated requests
2. **Network issues**: Firewall or connectivity problems
3. **Rate limiting**: Too many requests in short time

**Solutions**:
1. **Use DuckDuckGo** (recommended): `--backend duckduckgo`
2. **Add timeout**: Increase timeout if network is slow
3. **Check connectivity**: Ensure internet connection works
4. **Try different backend**: Test with Wikipedia or other engines

### Command Hangs

**Problem**: CLI command doesn't respond or takes too long

**Solutions**:
```bash
# Use timeout command
timeout 30 dart run ddgs text -q "test" -m 5 -b duckduckgo

# Reduce max results
dart run ddgs text -q "test" -m 3 -b duckduckgo

# Use faster backend
dart run ddgs text -q "test" -m 5 -b wikipedia
```

## Performance Testing

```bash
# Test response time
time dart run ddgs text -q "test" -m 5 -b duckduckgo

# Test different backends
for backend in duckduckgo wikipedia; do
  echo "Testing $backend..."
  time dart run ddgs text -q "test" -m 3 -b $backend
done
```

## Backend Reliability

| Backend | Text | Images | Videos | News | Reliability |
|---------|------|--------|--------|------|-------------|
| DuckDuckGo | ✅ | ✅ | ✅ | ✅ | **High** |
| Wikipedia | ✅ | ❌ | ❌ | ❌ | High |
| Brave | ⚠️ | ❌ | ❌ | ❌ | Medium |
| Mojeek | ⚠️ | ❌ | ❌ | ❌ | Medium |
| Bing | ⚠️ | ❌ | ❌ | ❌ | Low (anti-scraping) |
| Yahoo | ⚠️ | ❌ | ❌ | ❌ | Low |
| Yandex | ⚠️ | ❌ | ❌ | ❌ | Low |

**Legend**: ✅ Works reliably | ⚠️ May be blocked | ❌ Not supported

**Recommendation**: Always use `duckduckgo` as the backend for production use.

## Integration Testing

### Test in Your Code

```dart
import 'package:ddgs/ddgs.dart';
import 'package:test/test.dart';

void main() {
  test('Search returns results', () async {
    final ddgs = DDGS();
    final results = await ddgs.text(
      'Dart programming',
      maxResults: 5,
      backend: 'duckduckgo',
    );
    
    expect(results, isNotEmpty);
    expect(results.first['title'], isNotNull);
    expect(results.first['href'], isNotNull);
    
    ddgs.close();
  });
}
```

## CI/CD Testing

```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: dart-lang/setup-dart@v1
      - run: dart pub get
      - run: dart test
      - run: dart analyze
      - run: dart format --output=none --set-exit-if-changed .
```
