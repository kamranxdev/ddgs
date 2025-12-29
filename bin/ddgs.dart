/// CLI tool for DDGS.
library;

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:ddgs/ddgs.dart';

const String version = '9.6.0';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('text')
    ..addCommand('images')
    ..addCommand('videos')
    ..addCommand('news')
    ..addCommand('books')
    ..addFlag('version', abbr: 'v', negatable: false, help: 'Print version')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print help');

  // Setup common options for all commands
  for (final cmd in ['text', 'images', 'videos', 'news', 'books']) {
    parser.commands[cmd]!
      ..addOption('query', abbr: 'q', help: 'Search query', mandatory: true)
      ..addOption(
        'region',
        abbr: 'r',
        help: 'Region (e.g., us-en)',
        defaultsTo: 'us-en',
      )
      ..addOption(
        'safesearch',
        abbr: 's',
        help: 'Safe search (on/moderate/off)',
        defaultsTo: 'moderate',
      )
      ..addOption('timelimit', abbr: 't', help: 'Time limit (d/w/m/y)')
      ..addOption(
        'max-results',
        abbr: 'm',
        help: 'Maximum results',
        defaultsTo: '10',
      )
      ..addOption('page', abbr: 'p', help: 'Page number', defaultsTo: '1')
      ..addOption(
        'backend',
        abbr: 'b',
        help: 'Search backend to use (recommended: duckduckgo)',
        defaultsTo: 'duckduckgo',
        allowed: [
          'auto',
          'bing',
          'brave',
          'duckduckgo',
          'mojeek',
          'yahoo',
          'yandex',
          'wikipedia',
        ],
      )
      ..addOption('proxy', help: 'Proxy URL')
      ..addOption('output', abbr: 'o', help: 'Output file (json or csv)')
      ..addFlag('json', help: 'Output as JSON');
  }

  try {
    final results = parser.parse(arguments);

    if (results['version'] == true) {
      stdout.writeln('DDGS version $version');
      exit(0);
    }

    if (results['help'] == true || results.command == null) {
      printUsage(parser);
      exit(0);
    }

    final command = results.command!;
    await executeCommand(command);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    printUsage(parser);
    exit(1);
  } on Exception catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}

void printUsage(ArgParser parser) {
  stdout
    ..writeln('DDGS | Dux Distributed Global Search')
    ..writeln()
    ..writeln('Usage: ddgs <command> [options]')
    ..writeln()
    ..writeln('Commands:')
    ..writeln('  text      Text search')
    ..writeln('  images    Image search')
    ..writeln('  videos    Video search')
    ..writeln('  news      News search')
    ..writeln('  books     Books search')
    ..writeln()
    ..writeln('Options:')
    ..writeln(parser.usage)
    ..writeln()
    ..writeln('Example:')
    ..writeln(
      '  ddgs text -q "python programming" -r us-en -m 5 -b duckduckgo',
    );
}

Future<void> executeCommand(ArgResults command) async {
  final query = command['query'] as String;
  final region = command['region'] as String;
  final safesearch = command['safesearch'] as String;
  final timelimit = command['timelimit'] as String?;
  final maxResults = int.parse(command['max-results'] as String);
  final page = int.parse(command['page'] as String);
  final backend = command['backend'] as String;
  final proxy = command['proxy'] as String?;
  final outputFile = command['output'] as String?;
  final jsonOutput = command['json'] as bool;

  final ddgs = DDGS(proxy: proxy);

  try {
    List<Map<String, dynamic>> results;

    switch (command.name) {
      case 'text':
        results = await ddgs.text(
          query,
          region: region,
          safesearch: safesearch,
          timelimit: timelimit,
          maxResults: maxResults,
          page: page,
          backend: backend,
        );
        break;
      case 'images':
        results = await ddgs.images(
          query,
          region: region,
          safesearch: safesearch,
          timelimit: timelimit,
          maxResults: maxResults,
          page: page,
          backend: backend,
        );
        break;
      case 'videos':
        results = await ddgs.videos(
          query,
          region: region,
          safesearch: safesearch,
          timelimit: timelimit,
          maxResults: maxResults,
          page: page,
          backend: backend,
        );
        break;
      case 'news':
        results = await ddgs.news(
          query,
          region: region,
          safesearch: safesearch,
          timelimit: timelimit,
          maxResults: maxResults,
          page: page,
          backend: backend,
        );
        break;
      case 'books':
        results = await ddgs.books(
          query,
          region: region,
          safesearch: safesearch,
          maxResults: maxResults,
          page: page,
          backend: backend,
        );
        break;
      default:
        throw Exception('Unknown command: ${command.name}');
    }

    if (outputFile != null) {
      await saveResults(results, outputFile);
      stdout.writeln('Results saved to $outputFile');
    } else if (jsonOutput) {
      stdout.writeln(jsonEncode(results));
    } else {
      printResults(results);
    }
  } finally {
    ddgs.close();
  }
}

void printResults(List<Map<String, dynamic>> results) {
  for (var i = 0; i < results.length; i++) {
    stdout
      ..writeln('${i + 1}. ${'=' * 70}')
      ..writeln();
    final result = results[i];
    result.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        stdout.writeln('$key: $value');
      }
    });
  }
}

Future<void> saveResults(
  List<Map<String, dynamic>> results,
  String filename,
) async {
  final file = File(filename);

  if (filename.endsWith('.json')) {
    await file.writeAsString(jsonEncode(results));
  } else if (filename.endsWith('.csv')) {
    final buffer = StringBuffer();
    if (results.isNotEmpty) {
      // Write header
      final keys = results.first.keys.toList();
      buffer.writeln(keys.join(','));

      // Write rows
      for (final result in results) {
        final values = keys.map((key) {
          final value = result[key]?.toString() ?? '';
          // Escape CSV values
          return '"${value.replaceAll('"', '""')}"';
        });
        buffer.writeln(values.join(','));
      }
    }
    await file.writeAsString(buffer.toString());
  } else {
    throw Exception('Unsupported file format. Use .json or .csv');
  }
}
