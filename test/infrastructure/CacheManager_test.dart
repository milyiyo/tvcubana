import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tvcubana/infrastructure/CacheManager.dart';

// Guards CacheManager.hasCacheFor: a cache hit must require BOTH the 'date' and
// 'channels' preference keys to be present, and the requested date to be on or
// before the cached date. Previously the 'channels' key was loaded but never
// consulted (an unreachable guard re-checked 'date'), so a prefs state with
// 'date' present and 'channels' absent was reported as a valid cache, causing
// ICRTService.getChannels(false) to call retrieveChannels() and crash on
// json.decode(null).

void main() {
  // Cache is valid through cachedDate (end-of-week boundary). requested* dates
  // exercise the in-range (before/==) and expired (after) branches.
  const cachedDate = '2026-09-12';
  const requestedBefore = '2026-09-06'; // earlier -> hit
  const requestedOnBoundary = '2026-09-12'; // equal -> hit
  const requestedAfter = '2026-09-13'; // later -> expired
  const channelsJson = '[]';

  // SharedPreferences is a process-global singleton; reset to a clean store
  // before each test.
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('hasCacheFor: incomplete cache is never reported as valid', () {
    test('empty prefs -> false', () async {
      expect(await CacheManager.hasCacheFor(requestedBefore), isFalse);
    });

    test('only channels present (date missing) -> false', () async {
      SharedPreferences.setMockInitialValues({'channels': channelsJson});
      expect(await CacheManager.hasCacheFor(requestedBefore), isFalse);
    });

    test('only date present (channels missing, split-state) -> false',
        () async {
      // The exact state that crashed before the fix: 'date' set, 'channels'
      // absent. hasCacheFor must reject it so getChannels(false) falls back to
      // the network-fetch branch instead of calling retrieveChannels().
      SharedPreferences.setMockInitialValues({'date': cachedDate});
      expect(await CacheManager.hasCacheFor(requestedBefore), isFalse);
      expect(await CacheManager.hasCacheFor(requestedOnBoundary), isFalse);
      expect(await CacheManager.hasCacheFor(requestedAfter), isFalse);
    });
  });

  group('hasCacheFor: complete cache date semantics', () {
    test('both keys present, requested before cached -> true', () async {
      SharedPreferences.setMockInitialValues({
        'date': cachedDate,
        'channels': channelsJson,
      });
      expect(await CacheManager.hasCacheFor(requestedBefore), isTrue);
    });

    test('both keys present, requested == cached -> true', () async {
      SharedPreferences.setMockInitialValues({
        'date': cachedDate,
        'channels': channelsJson,
      });
      expect(await CacheManager.hasCacheFor(requestedOnBoundary), isTrue);
    });

    test('both keys present, requested after cached (expired) -> false',
        () async {
      SharedPreferences.setMockInitialValues({
        'date': cachedDate,
        'channels': channelsJson,
      });
      expect(await CacheManager.hasCacheFor(requestedAfter), isFalse);
    });
  });
}
