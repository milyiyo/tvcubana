// Regression tests for the loading lifecycle of TabCategories.
//
// Covers the "Categorías" tab zero-match loading bug: when the selected category
// filters match no programs for the day (or the feed resolves empty), the
// `isLoading` flag must still transition back to `false` so the spinner stops.
//
// Because ICRTService uses the top-level `package:http` `get()` and the cache is
// backed by `shared_preferences` (both platform-channel / network dependant),
// these tests stub the network via `HttpOverrides` (a mock `HttpClient` whose
// `openUrl` returns canned `HttpClientResponse`s for the known feed URLs) and
// stub the cache via `SharedPreferences.setMockInitialValues({})`.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tvcubana/ShowImdbImages.dart';
import 'package:tvcubana/widgets/TabCategories.dart';

// ---------------------------------------------------------------------------
// Minimal dart:io HttpClient mock that returns canned responses for the feed.
// `noSuchMethod` backs every member we don't use, so the surface stays small.
// ---------------------------------------------------------------------------

class _MockHttpClient implements HttpClient {
  final Future<HttpClientRequest> Function(String method, Uri url) _openUrl;
  _MockHttpClient(this._openUrl);

  @override
  Future<HttpClientRequest> openUrl(String method, [Uri url]) =>
      _openUrl(method, url);

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _MockRequest implements HttpClientRequest {
  final int status;
  final String body;
  final Future<void> Function() onBeforeClose;

  _MockRequest(this.status, this.body, {this.onBeforeClose});

  @override
  HttpHeaders headers = _MockHeaders();
  @override
  bool followRedirects;
  @override
  int maxRedirects;
  @override
  int contentLength;
  @override
  bool persistentConnection;

  @override
  Future<HttpClientResponse> close() async {
    if (onBeforeClose != null) await onBeforeClose();
    return _MockResponse(status, body);
  }

  @override
  Future<dynamic> addStream(Stream<List<int>> stream) async {}

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _MockHeaders implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void forEach(void Function(String name, List<String> values) f) {}

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _MockResponse extends Stream<List<int>> implements HttpClientResponse {
  final int statusCode;
  final List<int> _bytes;

  _MockResponse(this.statusCode, String body) : _bytes = utf8.encode(body);

  @override
  int contentLength = -1;
  @override
  bool isRedirect = false;
  @override
  bool persistentConnection = false;
  @override
  String reasonPhrase = '';
  @override
  HttpClientResponseCompressionState compressionState =
      HttpClientResponseCompressionState.notCompressed;
  @override
  HttpHeaders headers = _MockHeaders();
  @override
  List<Cookie> cookies = [];

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) {
    final c = StreamController<List<int>>();
    c.add(_bytes);
    c.close();
    return c.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

// ---------------------------------------------------------------------------
// Feed data helpers.
// ---------------------------------------------------------------------------

String get _todayStr {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}'
      '-${now.day.toString().padLeft(2, '0')}';
}

// A program item that is "today" but classified as news (does NOT match the
// default 'Películas' tag).
String _newsProgramBody() => json.encode([
      {
        '_id': 'n1',
        'descripcion': 'des',
        'descripcion_ampliada': 'descL',
        'duracion': '00:30',
        'fecha': '$_todayStr',
        'fecha_inicial': '$_todayStr',
        'fecha_final': '$_todayStr',
        'hora_inicio': '12:00:00',
        'hora_fin': '12:30:00',
        'titulo': 'Noticiero de prueba',
        'clasific': [
          {'clasificacion': 'noticias'}
        ]
      }
    ]);

// A program item that is "today" and classified as a movie (matches the
// default 'Películas' tag). Plain title so OMDB regexes won't fire.
String _movieProgramBody() => json.encode([
      {
        '_id': 'm1',
        'descripcion': 'des',
        'descripcion_ampliada': 'descL',
        'duracion': '01:30',
        'fecha': '$_todayStr',
        'fecha_inicial': '$_todayStr',
        'fecha_final': '$_todayStr',
        'hora_inicio': '20:00:00',
        'hora_fin': '21:30:00',
        'titulo': 'Pelicula de prueba categorizable',
        'clasific': [
          {'clasificacion': 'filme'}
        ]
      }
    ]);

String _oneChannelBody() => json.encode([
      {'_id': 'c1', 'nombre': 'Cubavision', 'logo': '', 'descripcion': 'desc'}
    ]);

/// Builds [TabCategories] wrapped in the [ShowImdbImages] provider it requires
/// (its `build` calls `context.watch<ShowImdbImages>()`).
Widget _pumpWidget() {
  return ChangeNotifierProvider<ShowImdbImages>(
    create: (_) => ShowImdbImages(),
    child: MaterialApp(
      home: Scaffold(
        body: TabCategories(),
      ),
    ),
  );
}

/// Runs [fn] inside an [HttpOverrides] zone that routes feed/OMDB HTTP calls to
/// [handler]. The handler receives `(method, url)` and returns the canned
/// [HttpClientRequest] (a `_MockRequest`).
Future<void> _withMockHttp(
  Future<void> Function() fn,
  HttpClientRequest Function(String method, Uri url) handler,
) async {
  await HttpOverrides.runZoned(
    fn,
    createHttpClient: (SecurityContext c) =>
        _MockHttpClient((method, url) async => handler(method, url)),
  );
}

HttpClientRequest _canned(int status, String body,
        {Future<void> Function() onBeforeClose}) =>
    _MockRequest(status, body, onBeforeClose: onBeforeClose);
HttpClientRequest _notFound() => _MockRequest(404, 'Not Found');

void main() {
  setUp(() {
    // Empty cache so ICRTService takes the HTTP path (resolved by the mock).
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'initial fetch with empty channels feed stops spinner (zero-match via empty feed)',
      (WidgetTester tester) async {
    await _withMockHttp(() async {
      await tester.pumpWidget(_pumpWidget());

      // While the fetch is pending, the spinner is shown.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // The empty-channel feed resolves successfully but matches nothing:
      // isLoading must transition to false (no spinner) and the list is empty.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // The chips render normally (build completed), proving the tab isn't
      // stuck in a broken state; no program content is shown.
      expect(find.text('Noticias'), findsOneWidget);
    }, (method, url) {
      if (url.host == 'eprog2.tvcdigital.cu' && url.path == '/canales') {
        // Empty (but 200) channel list.
        return _canned(200, '[]');
      }
      if (url.host == 'eprog2.tvcdigital.cu' &&
          url.path.startsWith('/programacion/')) {
        return _canned(200, '[]');
      }
      if (url.host == 'www.omdbapi.com') {
        return _canned(200, '{}');
      }
      return _notFound();
    });
  });

  testWidgets(
      'initial fetch with populated channels but non-matching programs stops spinner (zero-match via filter)',
      (WidgetTester tester) async {
    await _withMockHttp(() async {
      await tester.pumpWidget(_pumpWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Channels exist and programs resolve, but the only program is news and
      // the default tag is 'Películas' -> no match. The spinner must stop and
      // the (non-matching) program title must NOT be rendered.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Noticiero de prueba'), findsNothing);
    }, (method, url) {
      if (url.host == 'eprog2.tvcdigital.cu' && url.path == '/canales') {
        return _canned(200, _oneChannelBody());
      }
      if (url.host == 'eprog2.tvcdigital.cu' &&
          url.path.startsWith('/programacion/')) {
        // Only "today's" URL is populated; others empty (mirrors a real feed).
        if (url.path.endsWith('/$_todayStr')) {
          return _canned(200, _newsProgramBody());
        }
        return _canned(200, '[]');
      }
      if (url.host == 'www.omdbapi.com') {
        return _canned(200, '{}');
      }
      return _notFound();
    });
  });

  testWidgets(
      'happy path: matching programs render and spinner stops (no regression)',
      (WidgetTester tester) async {
    await _withMockHttp(() async {
      await tester.pumpWidget(_pumpWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // The movie matches the default 'Películas' tag: it is rendered and the
      // spinner has stopped.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Pelicula de prueba categorizable'), findsOneWidget);
    }, (method, url) {
      if (url.host == 'eprog2.tvcdigital.cu' && url.path == '/canales') {
        return _canned(200, _oneChannelBody());
      }
      if (url.host == 'eprog2.tvcdigital.cu' &&
          url.path.startsWith('/programacion/')) {
        if (url.path.endsWith('/$_todayStr')) {
          return _canned(200, _movieProgramBody());
        }
        return _canned(200, '[]');
      }
      if (url.host == 'www.omdbapi.com') {
        return _canned(200, '{}');
      }
      return _notFound();
    });
  });

  testWidgets(
      'filter change to a zero-match category shows the spinner while refetching, then settles empty',
      (WidgetTester tester) async {
    // Gate used to hold the second (filter-change) fetch open so we can observe
    // the spinner that the fix introduces at the start of chargeList. `null`
    // means "don't gate this request"; only the first /canales call after the
    // filter change is gated.
    Completer<void> gate;

    await _withMockHttp(() async {
      await tester.pumpWidget(_pumpWidget());
      await tester.pumpAndSettle();

      // Sanity: the default 'Películas' tag loaded the movie.
      expect(find.text('Pelicula de prueba categorizable'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Clear the cache so the next fetch takes the (gated) HTTP path again.
      SharedPreferences.setMockInitialValues({});
      // The next /canales call must hang on the gate until opened below.
      gate = Completer<void>();

      // Deselect 'Películas' (the only selected chip) -> tags becomes [] and
      // the new fetch matches nothing.
      await tester.tap(find.text('Películas'));
      await tester.pump();

      // While the refetch is gated open, the fix must have set isLoading = true.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // The previously-rendered movie is cleared.
      expect(find.text('Pelicula de prueba categorizable'), findsNothing);

      // Release the gated fetch; with no tag selected, zero items match, so the
      // spinner must stop and the list stay empty.
      gate.complete();
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Pelicula de prueba categorizable'), findsNothing);
    }, (method, url) {
      if (url.host == 'eprog2.tvcdigital.cu' && url.path == '/canales') {
        final hook = gate == null ? null : () => gate.future;
        return _canned(200, _oneChannelBody(), onBeforeClose: hook);
      }
      if (url.host == 'eprog2.tvcdigital.cu' &&
          url.path.startsWith('/programacion/')) {
        // Initial load needs a movie to satisfy the sanity check; once
        // 'Películas' is deselected (tags == []) the movie no longer matches,
        // exercising the zero-match completion path on a filter change.
        if (url.path.endsWith('/$_todayStr')) {
          return _canned(200, _movieProgramBody());
        }
        return _canned(200, '[]');
      }
      if (url.host == 'www.omdbapi.com') {
        return _canned(200, '{}');
      }
      return _notFound();
    });
  });
}
