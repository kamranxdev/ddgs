#!/usr/bin/env dart
/// Simple example demonstrating basic DDGS library usage.
///
/// Run with: dart run bin/example.dart

import 'package:ddgs/ddgs.dart';

void main() async {
  // Create a DDGS instance
  final ddgs = DDGS();

  try {
    // Example 1: Simple text search
    print('📚 Example 1: Simple Text Search\n');
    await simpleTextSearch(ddgs);

    // Example 2: Typed text search (strongly-typed results)
    print('\n📚 Example 2: Typed Text Search\n');
    await typedTextSearch(ddgs);

    // Example 3: Image search
    print('\n📚 Example 3: Image Search\n');
    await imageSearch(ddgs);

    // Example 4: Search with options
    print('\n📚 Example 4: Search with Custom Options\n');
    await searchWithOptions(ddgs);

    // Example 5: Instant answers
    print('\n📚 Example 5: Instant Answers\n');
    await instantAnswersExample(ddgs);

    print('\n✨ All examples completed!\n');
  } catch (e) {
    print('Error: $e');
  } finally {
    ddgs.close();
  }
}

Future<void> simpleTextSearch(DDGS ddgs) async {
  print('Searching for: "Hello Dart"');
  
  final results = await ddgs.text(
    'Hello Dart',
    maxResults: 3,
  );

  print('Found ${results.length} results:\n');
  for (var i = 0; i < results.length && i < 3; i++) {
    final result = results[i];
    print('${i + 1}. ${result['title']}');
    print('   URL: ${result['href']}');
    print('');
  }
}

Future<void> typedTextSearch(DDGS ddgs) async {
  print('Searching for: "Web Development"');
  
  final results = await ddgs.textTyped(
    'Web Development',
    options: const SearchOptions(maxResults: 2),
  );

  print('Found ${results.length} results:\n');
  for (final result in results) {
    print('• ${result.title}');
    print('  URL: ${result.href}');
    final preview = result.body.length > 80 ? result.body.substring(0, 80) : result.body;
    print('  Summary: $preview...');
    print('');
  }
}

Future<void> imageSearch(DDGS ddgs) async {
  print('Searching for images: "nature photography"');
  
  final results = await ddgs.imagesTyped(
    'nature photography',
    options: const SearchOptions(maxResults: 2),
  );

  print('Found ${results.length} images:\n');
  for (final result in results) {
    print('• ${result.title}');
    print('  Image: ${result.imageUrl}');
    if (result.width != null && result.height != null) {
      print('  Size: ${result.width}x${result.height}');
    }
    print('');
  }
}

Future<void> searchWithOptions(DDGS ddgs) async {
  print('Searching for: "Python" in UK region with strict safe search');
  
  final results = await ddgs.text(
    'Python',
    region: 'uk-en',
    safesearch: 'on',
    maxResults: 2,
  );

  print('Found ${results.length} results:\n');
  for (final result in results) {
    print('• ${result['title']}');
    print('');
  }
}

Future<void> instantAnswersExample(DDGS ddgs) async {
  print('Getting instant answer for: "What is Dart?"');
  
  final answer = await ddgs.instantAnswer('What is Dart?');
  
  if (answer != null && answer.hasContent) {
    print('Answer: ${answer.answer}');
    print('Source: ${answer.source}');
    print('Type: ${answer.type.name}');
  } else {
    print('No instant answer available for this query');
  }
}
