/// Search options and configuration classes.
library;

/// Supported search regions with human-readable names.
enum SearchRegion {
  usEnglish('us-en', 'United States (English)'),
  ukEnglish('uk-en', 'United Kingdom (English)'),
  germanGermany('de-de', 'Germany (German)'),
  frenchFrance('fr-fr', 'France (French)'),
  spanishSpain('es-es', 'Spain (Spanish)'),
  italianItaly('it-it', 'Italy (Italian)'),
  japaneseJapan('jp-jp', 'Japan (Japanese)'),
  chineseCn('cn-zh', 'China (Chinese)'),
  russianRussia('ru-ru', 'Russia (Russian)'),
  brazilPortuguese('br-pt', 'Brazil (Portuguese)'),
  indiaEnglish('in-en', 'India (English)'),
  australiaEnglish('au-en', 'Australia (English)'),
  canadaEnglish('ca-en', 'Canada (English)'),
  global('wt-wt', 'Global/Worldwide');

  final String code;
  final String displayName;

  const SearchRegion(this.code, this.displayName);

  /// Parse region code to enum.
  static SearchRegion fromCode(String code) => SearchRegion.values.firstWhere(
      (r) => r.code == code.toLowerCase(),
      orElse: () => SearchRegion.global,
    );
}

/// Safe search level options.
enum SafeSearchLevel {
  off('off', 'No filtering'),
  moderate('moderate', 'Moderate filtering'),
  strict('on', 'Strict filtering');

  final String code;
  final String description;

  const SafeSearchLevel(this.code, this.description);
}

/// Time limit filter options.
enum TimeLimit {
  day('d', 'Past 24 hours'),
  week('w', 'Past week'),
  month('m', 'Past month'),
  year('y', 'Past year'),
  none(null, 'All time');

  final String? code;
  final String displayName;

  const TimeLimit(this.code, this.displayName);
}

/// Search options configuration.
class SearchOptions {

  const SearchOptions({
    this.region = SearchRegion.usEnglish,
    this.safeSearch = SafeSearchLevel.moderate,
    this.timeLimit = TimeLimit.none,
    this.maxResults = 10,
    this.page = 1,
    this.backend = 'auto',
    this.includeMetadata = false,
    this.minRelevanceScore,
    this.language,
    this.fileType,
    this.imageSize,
    this.imageColor,
  });
  /// Search region for localized results.
  final SearchRegion region;

  /// Safe search filtering level.
  final SafeSearchLevel safeSearch;

  /// Time limit for results.
  final TimeLimit timeLimit;

  /// Maximum number of results to return.
  final int maxResults;

  /// Page number for pagination (1-indexed).
  final int page;

  /// Backend engine(s) to use.
  final String backend;

  /// Whether to include result metadata.
  final bool includeMetadata;

  /// Minimum relevance score (0-100).
  final int? minRelevanceScore;

  /// Language filter for results.
  final String? language;

  /// File type filter (for images).
  final String? fileType;

  /// Image size filter.
  final ImageSize? imageSize;

  /// Image color filter.
  final ImageColor? imageColor;

  /// Create a copy with modified values.
  SearchOptions copyWith({
    SearchRegion? region,
    SafeSearchLevel? safeSearch,
    TimeLimit? timeLimit,
    int? maxResults,
    int? page,
    String? backend,
    bool? includeMetadata,
    int? minRelevanceScore,
    String? language,
    String? fileType,
    ImageSize? imageSize,
    ImageColor? imageColor,
  }) => SearchOptions(
      region: region ?? this.region,
      safeSearch: safeSearch ?? this.safeSearch,
      timeLimit: timeLimit ?? this.timeLimit,
      maxResults: maxResults ?? this.maxResults,
      page: page ?? this.page,
      backend: backend ?? this.backend,
      includeMetadata: includeMetadata ?? this.includeMetadata,
      minRelevanceScore: minRelevanceScore ?? this.minRelevanceScore,
      language: language ?? this.language,
      fileType: fileType ?? this.fileType,
      imageSize: imageSize ?? this.imageSize,
      imageColor: imageColor ?? this.imageColor,
    );

  /// Default options for quick searches.
  static const quick = SearchOptions(maxResults: 5);

  /// Options optimized for comprehensive results.
  static const comprehensive = SearchOptions(
    maxResults: 50,
    includeMetadata: true,
  );

  @override
  String toString() => 'SearchOptions(region: ${region.code}, '
      'safeSearch: ${safeSearch.code}, maxResults: $maxResults)';
}

/// Image size filter options.
enum ImageSize {
  small('Small'),
  medium('Medium'),
  large('Large'),
  wallpaper('Wallpaper');

  final String displayName;
  const ImageSize(this.displayName);
}

/// Image color filter options.
enum ImageColor {
  any('Any'),
  monochrome('Monochrome'),
  red('Red'),
  orange('Orange'),
  yellow('Yellow'),
  green('Green'),
  blue('Blue'),
  purple('Purple'),
  pink('Pink'),
  brown('Brown'),
  black('Black'),
  white('White');

  final String displayName;
  const ImageColor(this.displayName);
}

/// Search result caching configuration.
class CacheConfig {

  const CacheConfig({
    this.enabled = false,
    this.ttl = const Duration(minutes: 15),
    this.maxEntries = 100,
    this.cacheDirectory,
  });
  /// Whether caching is enabled.
  final bool enabled;

  /// Time-to-live for cached results.
  final Duration ttl;

  /// Maximum number of cached queries.
  final int maxEntries;

  /// Cache storage directory (null for memory-only).
  final String? cacheDirectory;

  /// Disabled cache config.
  static const disabled = CacheConfig();

  /// Memory-only cache with 15-minute TTL.
  static const memory = CacheConfig(enabled: true);

  /// Persistent cache with 1-hour TTL.
  static CacheConfig persistent(String directory) => CacheConfig(
        enabled: true,
        ttl: const Duration(hours: 1),
        cacheDirectory: directory,
      );
}

/// In-memory result cache with TTL support.
class ResultCache {

  ResultCache(this.config);
  final CacheConfig config;
  final Map<String, _CacheEntry> _cache = {};

  /// Generate cache key from query and options.
  String _generateKey(String category, String query, SearchOptions options) {
    final keyData = '$category:$query:${options.region.code}:'
        '${options.safeSearch.code}:${options.timeLimit.code}:'
        '${options.page}:${options.backend}';
    return keyData.hashCode.toString();
  }

  /// Get cached results if available and not expired.
  List<Map<String, dynamic>>? get(
    String category,
    String query,
    SearchOptions options,
  ) {
    if (!config.enabled) return null;

    final key = _generateKey(category, query, options);
    final entry = _cache[key];

    if (entry == null) return null;

    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }

    return entry.results;
  }

  /// Store results in cache.
  void put(
    String category,
    String query,
    SearchOptions options,
    List<Map<String, dynamic>> results,
  ) {
    if (!config.enabled) return;

    // Enforce max entries limit
    if (_cache.length >= config.maxEntries) {
      _evictOldest();
    }

    final key = _generateKey(category, query, options);
    _cache[key] = _CacheEntry(
      results: results,
      expiresAt: DateTime.now().add(config.ttl),
    );
  }

  /// Evict oldest cache entry.
  void _evictOldest() {
    if (_cache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.createdAt.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value.createdAt;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }

  /// Clear all cached results.
  void clear() => _cache.clear();

  /// Get cache statistics.
  CacheStats get stats => CacheStats(
        entries: _cache.length,
        maxEntries: config.maxEntries,
        ttl: config.ttl,
      );
}

class _CacheEntry {

  _CacheEntry({
    required this.results,
    required this.expiresAt,
  }) : createdAt = DateTime.now();
  final List<Map<String, dynamic>> results;
  final DateTime expiresAt;
  final DateTime createdAt;
}

/// Cache statistics.
class CacheStats {

  const CacheStats({
    required this.entries,
    required this.maxEntries,
    required this.ttl,
  });
  final int entries;
  final int maxEntries;
  final Duration ttl;

  double get utilizationPercent => entries / maxEntries * 100;

  @override
  String toString() =>
      'CacheStats(entries: $entries/$maxEntries, ttl: ${ttl.inMinutes}m)';
}
