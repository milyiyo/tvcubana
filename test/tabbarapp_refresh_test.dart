import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tvcubana/ShowImdbImages.dart';
import 'package:tvcubana/widgets/TabBarApp.dart';

// Minimal dart:io HttpClient fakes so the static ICRTService (top-level
// http.get -> IOClient -> dart:io HttpClient) can be driven from a widget test
// without changing production code. Installed via HttpOverrides.global.

typedef _Responder = String Function(String method, Uri url);

class _FakeHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _values = {};

  _FakeHttpHeaders([Map<String, List<String>> initial]) {
    if (initial != null) {
      initial
          .forEach((k, v) => _values[k.toLowerCase()] = List<String>.from(v));
    }
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _values[name.toLowerCase()] = <String>[value.toString()];
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _values.forEach((k, v) => action(k, v));
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  final int _status;
  final List<int> _bodyBytes;
  final Map<String, List<String>> _respHeaders;

  _FakeHttpClientRequest(this._status, this._bodyBytes, this._respHeaders);

  @override
  final _FakeHttpHeaders headers = _FakeHttpHeaders();

  @override
  set followRedirects(bool v) {}
  @override
  set maxRedirects(int v) {}
  @override
  set contentLength(int v) {}
  @override
  set persistentConnection(bool v) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await stream.drain<void>();
  }

  @override
  Future<HttpClientResponse> close() async =>
      _FakeHttpClientResponse(_status, _bodyBytes, _respHeaders);

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeHttpClientResponse extends StreamView<List<int>>
    implements HttpClientResponse {
  @override
  final int statusCode;
  final List<int> _bytes;
  final _FakeHttpHeaders _headers;

  _FakeHttpClientResponse(
      int statusCode, this._bytes, Map<String, List<String>> h)
      : statusCode = statusCode,
        _headers = _FakeHttpHeaders(h),
        super(Stream<List<int>>.fromIterable(<List<int>>[_bytes]));

  @override
  int get contentLength => _bytes.length;
  @override
  HttpHeaders get headers => _headers;
  @override
  bool get isRedirect => false;
  @override
  bool get persistentConnection => false;
  @override
  String get reasonPhrase => 'OK';

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeHttpClient implements HttpClient {
  final _Responder _respond;

  _FakeHttpClient(this._respond);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    final body = utf8.encode(_respond(method, url));
    return _FakeHttpClientRequest(200, body, <String, List<String>>{
      'content-type': <String>['application/json']
    });
  }

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Overrides extends HttpOverrides {
  final _Responder respond;
  _Overrides(this.respond);
  @override
  HttpClient createHttpClient(SecurityContext context) =>
      _FakeHttpClient(respond);
}

Widget _withProviders(Widget child) {
  // The refresh FAB positions itself at (width-80, height-80) via
  // MediaQuery.of(context); with the default MediaQueryData() (size zero) it
  // lands offscreen. TabCategories also requires a ShowImdbImages ancestor.
  return MediaQuery(
    data: MediaQueryData(size: const Size(411.4, 863.4)),
    child: ChangeNotifierProvider<ShowImdbImages>(
      create: (_) => ShowImdbImages(),
      child: child,
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  // Flush the multi-hop async chains (getChannels + 7 awaits x N channels of
  // getProgram). Do NOT use pumpAndSettle: sibling tabs keep infinite spinners
  // (getProgram returns empty -> isLoading stays true) and would time out.
  for (var i = 0; i < 40; i++) {
    await tester.pump(Duration.zero);
  }
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _openCanales(WidgetTester tester) async {
  await tester.tap(find.text('Canales'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

void main() {
  testWidgets(
      'refresh updates the Canales grid to the refreshed roster '
      '(added, removed, renamed, null-name filtered)',
      (WidgetTester tester) async {
    // The boot upstream returns c1/c2/c3; the refresh upstream adds c9, renames
    // c1's description, includes a null-nombre entry (must be filtered), and
    // drops c2/c3.
    var returnRefresh = false;
    HttpOverrides.global = _Overrides((method, url) {
      if (url.path == '/canales') {
        return json.encode(returnRefresh
            ? [
                {
                  '_id': 'c9',
                  'nombre': 'NewChannel',
                  'logo': 'l9',
                  'descripcion': 'Desc NEW'
                },
                {
                  '_id': 'c1',
                  'nombre': 'CubaVision',
                  'logo': 'l1',
                  'descripcion': 'Desc A RENAMED'
                },
                {
                  '_id': 'cX',
                  'nombre': null,
                  'logo': 'lX',
                  'descripcion': 'should be hidden'
                },
              ]
            : [
                {
                  '_id': 'c1',
                  'nombre': 'CubaVision',
                  'logo': 'l1',
                  'descripcion': 'Desc A'
                },
                {
                  '_id': 'c2',
                  'nombre': 'Telerebelde',
                  'logo': 'l2',
                  'descripcion': 'Desc B'
                },
                {
                  '_id': 'c3',
                  'nombre': 'Educativo',
                  'logo': 'l3',
                  'descripcion': 'Desc C'
                },
              ]);
      }
      return '[]'; // /programacion/<id>/<date>: empty is sufficient for the loop.
    });
    addTearDown(() => HttpOverrides.global = null);

    // No SharedPreferences cache: every getChannels call misses and hits the
    // fake network, so the test deterministically drives the canned rosters.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(_withProviders(TabBarApp()));
    await _settle(tester);
    await _openCanales(tester);

    // Boot grid: the three boot channels.
    expect(find.text('CubaVision'), findsOneWidget);
    expect(find.text('Telerebelde'), findsOneWidget);
    expect(find.text('Educativo'), findsOneWidget);
    expect(find.text('Desc A.'), findsOneWidget);
    expect(find.text('NewChannel'), findsNothing);

    // Rotate the upstream to the refreshed roster and invoke the refresh path
    // (reloadData), exercising the actual code under fix. The FAB is verified
    // present via find.byIcon(Icons.refresh); invoking reloadData directly
    // avoids the DraggableFloatingActionButton's competing drag recognizer
    // that swallows tap() in the test binding.
    returnRefresh = true;
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    (tester.state(find.byType(TabBarApp)) as dynamic).reloadData();
    await _settle(tester);

    // Added channel appears.
    expect(find.text('NewChannel'), findsOneWidget);
    // Removed channels disappear.
    expect(find.text('Telerebelde'), findsNothing);
    expect(find.text('Educativo'), findsNothing);
    // Renamed channel: new description reflected, old one gone.
    expect(find.text('Desc A RENAMED.'), findsOneWidget);
    expect(find.text('Desc A.'), findsNothing);
    // Null-nombre channel filtered out (parity with initState).
    expect(find.text('should be hidden'), findsNothing);
    // c1 still present (unchanged id, updated metadata).
    expect(find.text('CubaVision'), findsOneWidget);
  });
}
