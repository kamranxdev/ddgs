/// Example usage of DDGS library.
library;

import 'package:ddgs/ddgs.dart';

void main() async {
  // Create a DDGS instance
  final ddgs = DDGS();

  try {
    // Text search example
    print('=== Text Search ===');
    final textResults = await ddgs.text(
      'Dart programming language',
      maxResults: 5,
      backend: 'google',
    );

    for (final result in textResults) {
      print('Title: ${result['title']}');
      print('URL: ${result['href']}');
      print('Body: ${result['body']}');
      print('---');
    }

    // Image search example
    print('\n=== Image Search ===');
    final imageResults = await ddgs.images(
      'nature photography',
      maxResults: 3,
    );

    for (final result in imageResults) {
      print('Title: ${result['title']}');
      print('Image URL: ${result['image']}');
      print('Source: ${result['source']}');
      print('---');
    }

    // News search example
    print('\n=== News Search ===');
    final newsResults = await ddgs.news(
      'technology',
      maxResults: 3,
      timelimit: 'd', // last day
    );

    for (final result in newsResults) {
      print('Title: ${result['title']}');
      print('URL: ${result['url']}');
      print('Date: ${result['date']}');
      print('---');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    // Always close the DDGS instance to clean up resources
    ddgs.close();
  }
}
