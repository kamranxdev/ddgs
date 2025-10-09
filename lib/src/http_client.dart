/// HTTP client for making requests.
library;

import 'dart:io';
import 'package:http/http.dart' as http;
import 'exceptions.dart';

/// HTTP response wrapper.
class HttpResponse {
  final int statusCode;
  final String body;
  final List<int> bodyBytes;

  HttpResponse({
    required this.statusCode,
    required this.body,
    required this.bodyBytes,
  });
}

/// HTTP client with proxy support.
class HttpClient {
  final String? proxy;
  final Duration timeout;
  final bool verify;
  late final http.Client _client;

  HttpClient({
    this.proxy,
    Duration? timeout,
    this.verify = true,
  }) : timeout = timeout ?? const Duration(seconds: 10) {
    _client = http.Client();
  }

  /// Make an HTTP request.
  Future<HttpResponse> request(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Map<String, String>? params,
    dynamic body,
  }) async {
    try {
      // Add query parameters
      if (params != null && params.isNotEmpty) {
        url = url.replace(queryParameters: {
          ...url.queryParameters,
          ...params,
        });
      }

      http.Response response;
      final requestHeaders = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        ...?headers,
      };

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(url, headers: requestHeaders).timeout(timeout);
          break;
        case 'POST':
          response = await _client.post(url, headers: requestHeaders, body: body).timeout(timeout);
          break;
        default:
          throw DDGSException('Unsupported HTTP method: $method');
      }

      return HttpResponse(
        statusCode: response.statusCode,
        body: response.body,
        bodyBytes: response.bodyBytes,
      );
    } on SocketException catch (e) {
      throw DDGSException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      throw DDGSException('HTTP client error: $e');
    } on TimeoutException catch (e) {
      throw TimeoutException('Request timed out: $e');
    } catch (e) {
      throw DDGSException('Request failed: $e');
    }
  }

  /// Make a GET request.
  Future<HttpResponse> get(
    Uri url, {
    Map<String, String>? headers,
    Map<String, String>? params,
  }) {
    return request('GET', url, headers: headers, params: params);
  }

  /// Make a POST request.
  Future<HttpResponse> post(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
  }) {
    return request('POST', url, headers: headers, body: body);
  }

  void close() {
    _client.close();
  }
}
