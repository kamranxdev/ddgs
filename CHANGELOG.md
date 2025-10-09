# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2025-10-09

### Changed
- Package maintenance update

## [0.1.0] - 2025-10-09

### Added
- Initial Dart implementation of DDGS metasearch library
- Support for 10 search engines (7 text + 3 specialized):
  - **Text**: Bing, Brave, DuckDuckGo, Mojeek, Wikipedia, Yahoo, Yandex
  - **Images**: DuckDuckGo Images
  - **Videos**: DuckDuckGo Videos
  - **News**: DuckDuckGo News
- CLI tool with comprehensive command-line interface
- Async/await API for all search operations
- Proxy support (HTTP, HTTPS, SOCKS5)
- Region and language support
- Safe search filtering
- Time-based filtering
- Result deduplication
- Configurable timeout
- Extensible engine architecture

### Features
- Multi-engine metasearch aggregation
- Text, image, video, and news search capabilities
- Exception handling (DDGSException, RatelimitException, TimeoutException)
- HTML and JSON parsing for different search engines
- VQD authentication for DuckDuckGo APIs
- URL unwrapping for Bing and Yahoo results

### Documentation
- Comprehensive README with usage examples
- API documentation
- CLI usage guide with testing instructions
- Contributing guidelines
- MIT License

### Notes
- ⚠️ Google engine removed due to consistent anti-scraping blocking
- ✅ DuckDuckGo set as default backend for reliability
- ✅ All 10 remaining engines tested and working

## [Unreleased]

### Planned
- Books search implementation
- Additional reliable search engine backends
- Result caching
- Rate limiting improvements
- Performance optimizations
