import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tvcubana/models/Channel.dart';
import 'package:tvcubana/models/Program.dart';
import 'package:tvcubana/models/ProgramItem.dart';
import 'package:tvcubana/utils.dart';
import 'package:tvcubana/widgets/ChannelProgram.dart';

String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String _hhmmss(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

ProgramItem _airingItem(String title, {bool hhmm = true}) {
  final now = DateTime.now();
  final start = now.subtract(const Duration(hours: 2));
  final end = now.add(const Duration(hours: 2));
  return ProgramItem(
    'id_$title',
    'desc',
    'descLong',
    '60',
    getStrDate(now),
    getStrDate(start),
    getStrDate(end),
    hhmm ? _hhmm(start) : _hhmmss(start),
    hhmm ? _hhmm(end) : _hhmmss(end),
    title,
    [],
  );
}

String _cacheKey(String channelId) {
  final now = DateTime.now();
  final lastDayOfWeek = now.add(Duration(days: 7 - now.weekday));
  return 'programs_${channelId}_${getStrDate(lastDayOfWeek)}';
}

void main() {
  group('getTheCurrentAndNextProgram', () {
    test('returns the airing program for 5-char HH:mm times without throwing',
        () {
      final airing = _airingItem('Mesa Redonda', hhmm: true);
      final next = _airingItem('Siguiente', hhmm: true);
      final result = getTheCurrentAndNextProgram([airing, next]);
      expect(result[0], isNotNull);
      expect(result[0].title, 'Mesa Redonda');
      expect(result[1], isNotNull);
      expect(result[1].title, 'Siguiente');
    });

    test('no regression: 8-char HH:MM:SS times still work', () {
      final airing = _airingItem('Noticiero', hhmm: false);
      final next = _airingItem('Continuacion', hhmm: false);
      final result = getTheCurrentAndNextProgram([airing, next]);
      expect(result[0], isNotNull);
      expect(result[0].title, 'Noticiero');
      expect(result[1], isNotNull);
      expect(result[1].title, 'Continuacion');
    });
  });

  group('ChannelProgram route', () {
    testWidgets('renders without red-screening for HH:mm program times',
        (tester) async {
      final now = DateTime.now();
      final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final dates = List.generate(
          7, (i) => getStrDate(firstDayOfWeek.add(Duration(days: i))));
      final todayIdx = now.weekday - 1;

      final airing = _airingItem('Mesa Redonda E2E', hhmm: true);
      final programs = <Program>[];
      for (var i = 0; i < 7; i++) {
        programs.add(i == todayIdx
            ? Program(dates[i], [airing])
            : Program(dates[i], <ProgramItem>[]));
      }

      SharedPreferences.setMockInitialValues({
        _cacheKey('chE2E'):
            json.encode(programs.map((e) => e.toJson()).toList()),
      });

      await tester.pumpWidget(MaterialApp(
          home: ChannelProgram(Channel('chE2E', 'Cubavision', '', ''))));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 4));

      expect(tester.takeException(), isNot(isA<FormatException>()));
      expect(find.text('Mesa Redonda E2E'), findsOneWidget);
    });
  });
}
