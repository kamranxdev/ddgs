# Quick Start Guide

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd ddgs

# Install dependencies
dart pub get
```

## 5-Minute Tutorial

### 1. Run Your First Search

```bash
# Simple text search
dart run ddgs text -q "Dart programming" -m 5 -b duckduckgo
```

**Output:**
```
1. ======================================================================
title: Dart programming language
href: dart.dev
body: Dart is an approachable, portable, and productive language...

2. ======================================================================
title: Dart Tutorial - GeeksforGeeks
href: www.geeksforgeeks.org/dart/dart-tutorial/
body: Dart is an open-source general-purpose programming language...
```

### 2. Get JSON Output

```bash
dart run ddgs text -q "Flutter" -m 3 -b duckduckgo --json
```

**Output:**
```json
[
  {
    "title": "Flutter - Build apps for any screen",
    "href": "flutter.dev",
    "body": "Flutter transforms the app development process..."
  },
  ...
]
```

### 3. Search Images

```bash
dart run ddgs images -q "mountain sunset" -m 10 -b duckduckgo
```

### 4. Search Videos

```bash
dart run ddgs videos -q "dart tutorial" -m 5 -b duckduckgo
```

### 5. Search News

```bash
dart run ddgs news -q "technology" -m 10 -b duckduckgo
```

## Use in Your Code

### Example 1: Simple Search

```dart
import 'package:ddgs/ddgs.dart';

void main() async {
  final ddgs = DDGS();
  
  final results = await ddgs.text(
    'Dart programming',
    maxResults: 5,
    backend: 'duckduckgo',
  );
  
  for (final result in results) {
    print('${result['title']}: ${result['href']}');
  }
  
  ddgs.close();
}
```

### Example 2: Multiple Search Types

```dart
import 'package:ddgs/ddgs.dart';

void main() async {
  final ddgs = DDGS();
  
  // Text search
  print('=== Text Results ===');
  final textResults = await ddgs.text(
    'Flutter framework',
    maxResults: 3,
    backend: 'duckduckgo',
  );
  for (final r in textResults) {
    print('${r['title']}: ${r['href']}');
  }
  
  // Image search
  print('\n=== Image Results ===');
  final imageResults = await ddgs.images(
    'nature',
    maxResults: 5,
    backend: 'duckduckgo',
  );
  for (final r in imageResults) {
    print('${r['title']}: ${r['image']}');
  }
  
  // News search
  print('\n=== News Results ===');
  final newsResults = await ddgs.news(
    'technology',
    maxResults: 5,
    backend: 'duckduckgo',
  );
  for (final r in newsResults) {
    print('${r['title']}: ${r['href']}');
  }
  
  ddgs.close();
}
```

### Example 3: Error Handling

```dart
import 'package:ddgs/ddgs.dart';

void main() async {
  final ddgs = DDGS(timeout: Duration(seconds: 10));
  
  try {
    final results = await ddgs.text(
      'Dart programming',
      maxResults: 5,
      backend: 'duckduckgo',
    );
    
    if (results.isEmpty) {
      print('No results found');
    } else {
      for (final result in results) {
        print('${result['title']}: ${result['href']}');
      }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    ddgs.close();
  }
}
```

## Common CLI Commands

```bash
# Basic text search
dart run ddgs text -q "query" -m 10 -b duckduckgo

# Search with region
dart run ddgs text -q "query" -r us-en -m 10 -b duckduckgo

# Search with safe search
dart run ddgs text -q "query" -s on -m 10 -b duckduckgo

# Save to file
dart run ddgs text -q "query" -m 10 -b duckduckgo -o output.json --json

# Image search with filters
dart run ddgs images -q "sunset" -m 20 -b duckduckgo

# News with region
dart run ddgs news -q "technology" -r us-en -m 15 -b duckduckgo
```

## Next Steps

1. **Read the full documentation**: See [README.md](README.md)
2. **Check API reference**: See [API.md](API.md)
3. **Learn testing**: See [TESTING.md](TESTING.md)
4. **View examples**: Check `example/example.dart`
5. **Run tests**: `dart test`

## Tips

✅ **Always use `duckduckgo` backend** for reliable results  
✅ **Start with small maxResults** (3-5) for testing  
✅ **Use --json flag** for programmatic parsing  
✅ **Add error handling** in production code  
✅ **Close DDGS instance** after use to free resources  

## Troubleshooting

**Q: No results returned?**  
A: Use `--backend duckduckgo` - other engines may be blocked

**Q: Command hangs?**  
A: Reduce `--max-results` or use `timeout` command

**Q: Need faster results?**  
A: Use `wikipedia` backend for simple queries

See [TESTING.md](TESTING.md) for detailed troubleshooting.
